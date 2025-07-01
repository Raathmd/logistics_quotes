defmodule LogisticsQuotes.Domain do
  use Ash.Domain

  resources do
    resource(LogisticsQuotes.Organization)
    resource(LogisticsQuotes.Account)
    resource(LogisticsQuotes.User)
    resource(LogisticsQuotes.Branch)
    resource(LogisticsQuotes.Quote)
    resource(LogisticsQuotes.QuoteItem)
    resource(LogisticsQuotes.QuoteSundry)
    resource(LogisticsQuotes.QuoteRate)
  end
end
