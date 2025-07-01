defmodule LogisticsQuotesWeb.PageController do
  use LogisticsQuotesWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
