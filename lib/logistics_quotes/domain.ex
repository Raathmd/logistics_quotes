defmodule LogisticsQuotes.Domain do
  use Ash.Domain

  resources do
    resource(LogisticsQuotes.Organization)
    resource(LogisticsQuotes.Account)
    resource(LogisticsQuotes.User)
    resource(LogisticsQuotes.Branch)
  end
end
