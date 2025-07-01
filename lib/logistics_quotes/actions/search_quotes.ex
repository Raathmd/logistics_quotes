defmodule LogisticsQuotes.Actions.SearchQuotes do
  @moduledoc """
  Manual action for searching quotes via FreightWare API
  """

  use Ash.Resource.ManualRead

  def read(ash_query, _ecto_query, _opts, _context) do
    filters = Ash.Query.get_argument(ash_query, :filters) || %{}

    # Get session key from context or configuration
    session_key = get_session_key()

    case LogisticsQuotes.FreightWareAPI.search_quotes(filters, session_key) do
      {:ok, quotes_data} ->
        quotes =
          Enum.map(quotes_data, fn quote_data ->
            struct(LogisticsQuotes.Quote, quote_data)
          end)

        {:ok, quotes}

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
end
