defmodule LogisticsQuotesWeb.DashboardLive do
  use LogisticsQuotesWeb, :live_view
  alias LogisticsQuotes.Domain
  alias LogisticsQuotes.{Domain, Quote}

  def mount(_params, _session, socket) do
    # For demo purposes, we'll use a mock organization
    # In a real app, this would come from the current user's session
    organization_id = "demo-org-id"

    # Get online users grouped by branch
    online_users = get_online_users_by_branch(organization_id)

    # Get accounts for the organization (for account selection)
    accounts = get_accounts_for_organization(organization_id)

    # Initialize search form
    search_form = %{
      "account_id" => "",
      "quote_number" => "",
      "reference" => "",
      "from_date" => "",
      "to_date" => ""
    }

    {:ok,
     socket
     |> assign(:online_users, online_users)
     |> assign(:accounts, accounts)
     |> assign(:search_form, search_form)
     |> assign(:search_results, [])
     |> assign(:loading, false)
     |> assign(:organization_name, "Acme Corp")}
  end

  def handle_event("search_quotes", %{"search" => search_params}, socket) do
    case search_params["account_id"] do
      "" ->
        {:noreply, put_flash(socket, :error, "Please select an account")}

      _account_id ->
        # Build filters for the API call
        filters = build_search_filters(search_params)

        # Call the search action
        case Ash.read!(Quote, action: :search, domain: Domain, args: [filters: filters]) do
          {:ok, quotes} ->
            {:noreply,
             socket
             |> assign(:search_results, quotes)
             |> assign(:search_form, search_params)
             |> put_flash(:info, "Found #{length(quotes)} quotes")}

          {:error, error} ->
            {:noreply,
             socket
             |> put_flash(:error, "Search failed: #{inspect(error)}")
             |> assign(:loading, false)}
        end
    end
  end

  def handle_event("quick_quote", _params, socket) do
    # For demo purposes, we'll show a success message
    # In a real app, this would open a quick quote form
    {:noreply, put_flash(socket, :info, "Quick quote feature coming soon!")}
  end

  def handle_event("validate_search", %{"search" => search_params}, socket) do
    {:noreply, assign(socket, :search_form, search_params)}
  end

  defp get_online_users_by_branch(_organization_id) do
    # Mock data for demo - in real app, this would query the database
    # and filter by last_seen_at within the last 5 minutes
    %{
      "Main Office" => [
        %{name: "John Doe", status: "online"},
        %{name: "Sarah Wilson", status: "online"}
      ],
      "Warehouse A" => [
        %{name: "Mike Johnson", status: "online"}
      ],
      "Regional Hub" => [
        %{name: "Emma Davis", status: "away"}
      ]
    }
  end

  defp get_accounts_for_organization(_organization_id) do
    # Mock data for demo - in real app, this would query the database
    [
      %{id: "account-1", name: "ABC Shipping Ltd"},
      %{id: "account-2", name: "Global Transport Co"},
      %{id: "account-3", name: "Express Logistics Inc"}
    ]
  end

  defp build_search_filters(search_params) do
    search_params
    |> Enum.reject(fn {_key, value} -> value == "" end)
    |> Map.new()
  end
end
