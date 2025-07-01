defmodule LogisticsQuotes.FreightWareAPI do
  @moduledoc """
  HTTP client for FreightWare API integration
  """

  require Logger

  @base_url "http://tragar-db.dovetail.co.za:5001/WebServices/web"
  @api_version "V2"

  def fw_login do
    url = "#{@base_url}/FreightWare/#{@api_version}/system/auth/login"

    headers = [
      {"Accept", "*/*"},
      {"Content-Type", "application/json"}
    ]

    body =
      Jason.encode!(%{
        "username" => System.get_env("FREIGHTWARE_USERNAME") || "demo_user",
        "password" => System.get_env("FREIGHTWARE_PASSWORD") || "demo_pass"
      })

    case Req.post(url, headers: headers, body: body) do
      {:ok, %{status: 200, headers: response_headers}} ->
        case List.keyfind(response_headers, "x-freightware", 0) do
          {"x-freightware", token} ->
            {:ok, token}

          nil ->
            {:error, "No x-freightware token in response headers"}
        end

      {:ok, %{status: status, body: body}} ->
        Logger.error("Login failed with status #{status}: #{inspect(body)}")
        {:error, "Login failed with status #{status}"}

      {:error, reason} ->
        Logger.error("Login request failed: #{inspect(reason)}")
        {:error, reason}
    end
  end

  def search_quotes(filters \\ %{}, session_key) do
    url = "#{@base_url}/FreightWare/V1/quotes/"

    params = if map_size(filters) > 0, do: [filters: Jason.encode!(filters)], else: []

    case Req.get(url, headers: headers(session_key), params: params) do
      {:ok, %{status: 200, body: body}} ->
        quotes = parse_quotes_response(body)
        {:ok, quotes}

      {:ok, %{status: status, body: body}} ->
        Logger.error("Search quotes failed with status #{status}: #{inspect(body)}")
        {:error, "Search failed with status #{status}"}

      {:error, reason} ->
        Logger.error("Search quotes request failed: #{inspect(reason)}")
        {:error, reason}
    end
  end

  def quick_quote(shipment_data, session_key) do
    url = "#{@base_url}/FreightWare/V1/quotes/quick"

    case Req.post(url, headers: headers(session_key), json: shipment_data) do
      {:ok, %{status: 200, body: body}} ->
        quote = parse_quote_response(body)
        {:ok, quote}

      {:ok, %{status: status, body: body}} ->
        Logger.error("Quick quote failed with status #{status}: #{inspect(body)}")
        {:error, "Quick quote failed with status #{status}"}

      {:error, reason} ->
        Logger.error("Quick quote request failed: #{inspect(reason)}")
        {:error, reason}
    end
  end

  def create_quote(quote_data, session_key) do
    url = "#{@base_url}/FreightWare/V1/quotes"

    case Req.post(url, headers: headers(session_key), json: quote_data) do
      {:ok, %{status: 201, body: body}} ->
        quote = parse_quote_response(body)
        {:ok, quote}

      {:ok, %{status: status, body: body}} ->
        Logger.error("Create quote failed with status #{status}: #{inspect(body)}")
        {:error, "Create quote failed with status #{status}"}

      {:error, reason} ->
        Logger.error("Create quote request failed: #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp headers(session_key) do
    [
      {"Accept", "application/json"},
      {"Content-Type", "application/json"},
      {"x-freightware", session_key}
    ]
  end

  defp parse_quotes_response(body) when is_list(body) do
    Enum.map(body, &parse_quote_data/1)
  end

  defp parse_quotes_response(body) when is_map(body) do
    [parse_quote_data(body)]
  end

  defp parse_quote_response(body) when is_map(body) do
    parse_quote_data(body)
  end

  defp parse_quote_data(data) when is_map(data) do
    %{
      quote_number: data["quote_number"],
      quote_date: parse_date(data["quote_date"]),
      account_reference: data["account_reference"],
      shipper_reference: data["shipper_reference"],
      service_type: data["service_type"],
      status: data["status"],
      freight_charge: parse_decimal(data["freight_charge"]),
      total_charge: parse_decimal(data["total_charge"])
    }
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
