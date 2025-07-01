defmodule LogisticsQuotes.Actions.QuickQuote do
  @moduledoc """
  Manual action for getting quick quotes via FreightWare API
  """

  use Ash.Resource.ManualCreate

  def create(changeset, _opts, _context) do
    shipment_data = Ash.Changeset.get_argument(changeset, :shipment_data)

    # Get session key from context or configuration
    session_key = get_session_key()

    case LogisticsQuotes.FreightWareAPI.quick_quote(shipment_data, session_key) do
      {:ok, quote_data} ->
        quote = build_quote_with_rates(quote_data)
        {:ok, quote}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp get_session_key do
    case LogisticsQuotes.FreightWareAPI.fw_login() do
      {:ok, token} -> token
      {:error, _reason} -> nil
    end
  end

  defp build_quote_with_rates(quote_data) do
    # Build the main quote struct
    quote = struct(LogisticsQuotes.Quote, quote_data)

    # Parse rates from the response
    rates = parse_rates(quote_data["rates"] || [])
    items = parse_items(quote_data["items"] || [])
    sundries = parse_sundries(quote_data["sundries"] || [])

    # Return the quote with associated data
    %{quote | rates: rates, items: items, sundries: sundries}
  end

  defp parse_rates(rates_data) do
    Enum.map(rates_data, fn rate_data ->
      struct(LogisticsQuotes.QuoteRate, %{
        service_type: rate_data["service_type"],
        freight_charge: parse_decimal(rate_data["freight_charge"]),
        sundry_charge: parse_decimal(rate_data["sundry_charge"]),
        insurance_charge: parse_decimal(rate_data["insurance_charge"]),
        tax_charge: parse_decimal(rate_data["tax_charge"]),
        total_charge: parse_decimal(rate_data["total_charge"]),
        currency: rate_data["currency"] || "ZAR"
      })
    end)
  end

  defp parse_items(items_data) do
    Enum.map(items_data, fn item_data ->
      struct(LogisticsQuotes.QuoteItem, %{
        quantity: item_data["quantity"] || 1,
        description: item_data["description"],
        total_weight: parse_decimal(item_data["total_weight"]),
        length: parse_decimal(item_data["length"]),
        width: parse_decimal(item_data["width"]),
        height: parse_decimal(item_data["height"])
      })
    end)
  end

  defp parse_sundries(sundries_data) do
    Enum.map(sundries_data, fn sundry_data ->
      struct(LogisticsQuotes.QuoteSundry, %{
        service_type: sundry_data["service_type"],
        sundry_code: sundry_data["sundry_code"],
        sundry_description: sundry_data["sundry_description"],
        sundry_direction: sundry_data["sundry_direction"],
        sundry_charge: parse_decimal(sundry_data["sundry_charge"]),
        sundry_currency: sundry_data["sundry_currency"] || "ZAR",
        sundry_taxable: sundry_data["sundry_taxable"] || false
      })
    end)
  end

  defp parse_decimal(nil), do: nil
  defp parse_decimal(value) when is_number(value), do: Decimal.new(value)

  defp parse_decimal(value) when is_binary(value) do
    case Decimal.parse(value) do
      {decimal, _} -> decimal
      :error -> nil
    end
  end
end
