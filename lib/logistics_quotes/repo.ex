defmodule LogisticsQuotes.Repo do
  use Ecto.Repo,
    otp_app: :logistics_quotes,
    adapter: Ecto.Adapters.SQLite3
end
