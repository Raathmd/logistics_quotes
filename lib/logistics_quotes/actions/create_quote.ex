defmodule LogisticsQuotes.Actions.CreateQuote do
  @moduledoc """
  Manual action for creating official quotes via FreightWare API
  """

  use Ash.Resource.ManualCreate

  def create(changeset, _opts, _context) do
    quote_data = Ash.Changeset.get_argument(changeset, :quote_data)

    # Get session key from context or configuration
    session_key = get_session_key()

    case LogisticsQuotes.FreightWareAPI.create_quote(quote_data, session_key) do
      {:ok, quote_data} ->
        quote = build_quote_from_response(quote_data)
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

  defp build_quote_from_response(quote_data) do
    # Build the main quote struct from API response
    quote_attrs = %{
      quote_number: quote_data["quote_number"],
      quote_date: parse_date(quote_data["quote_date"]),
      account_reference: quote_data["account_reference"],
      shipper_reference: quote_data["shipper_reference"],
      service_type: quote_data["service_type"],
      status: quote_data["status"] || "created",
      freight_charge: parse_decimal(quote_data["freight_charge"]),
      total_charge: parse_decimal(quote_data["total_charge"])
    }

    struct(LogisticsQuotes.Quote, quote_attrs)
  end

  defp parse_date(nil), do: nil

  defp parse_date(date_string) when is_binary(date_string) do
    case Date.from_iso8601(date_string) do
      {:ok, date} -> date
      {:error, _} -> nil
    end
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
