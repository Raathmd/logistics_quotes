defmodule LogisticsQuotesWeb.AccountsLive do
  use LogisticsQuotesWeb, :live_view
  alias LogisticsQuotes.Accounts.Account
  alias LogisticsQuotes.Organizations.Organization

  def mount(_params, _session, socket) do
    accounts = Ash.read!(Account, load: [:organization])
    organizations = Ash.read!(Organization)

    {:ok,
     socket
     |> assign(:page_title, "Accounts")
     |> assign(:active_nav, "accounts")
     |> assign(:accounts, accounts)
     |> assign(:organizations, organizations)
     |> assign(:show_form, false)
     |> assign(:selected_account, nil)
     |> assign(:form, to_form(%{}))}
  end

  def handle_event("new_account", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_form, true)
     |> assign(:selected_account, nil)
     |> assign(:form, to_form(%{}))}
  end

  def handle_event("edit_account", %{"id" => id}, socket) do
    account = Ash.get!(Account, id, load: [:organization])

    form_data = %{
      "name" => account.name,
      "api_key" => account.api_key,
      "api_secret" => account.api_secret,
      "organization_id" => account.organization_id
    }

    {:noreply,
     socket
     |> assign(:show_form, true)
     |> assign(:selected_account, account)
     |> assign(:form, to_form(form_data))}
  end

  def handle_event("cancel_form", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_form, false)
     |> assign(:selected_account, nil)
     |> assign(:form, to_form(%{}))}
  end

  def handle_event(
        "save_account",
        %{
          "name" => name,
          "api_key" => api_key,
          "api_secret" => api_secret,
          "organization_id" => org_id
        },
        socket
      ) do
    attrs = %{
      name: name,
      api_key: api_key,
      api_secret: api_secret,
      organization_id: org_id
    }

    result =
      if socket.assigns.selected_account do
        Ash.update!(socket.assigns.selected_account, attrs)
      else
        Ash.create!(Account, attrs)
      end

    accounts = Ash.read!(Account, load: [:organization])

    {:noreply,
     socket
     |> assign(:accounts, accounts)
     |> assign(:show_form, false)
     |> assign(:selected_account, nil)
     |> assign(:form, to_form(%{}))
     |> put_flash(:info, "Account saved successfully")}
  end

  def handle_event("delete_account", %{"id" => id}, socket) do
    account = Ash.get!(Account, id)
    Ash.destroy!(account)
    accounts = Ash.read!(Account, load: [:organization])

    {:noreply,
     socket
     |> assign(:accounts, accounts)
     |> put_flash(:info, "Account deleted successfully")}
  end

  def render(assigns) do
    ~H"""
    <LogisticsQuotesWeb.Layouts.app flash={@flash} current_user={assigns[:current_user]}>
      <div class="flex min-h-screen bg-gray-50">
        <!-- Sidebar Navigation -->
        <nav class="w-64 bg-white shadow-lg">
          <div class="p-6">
            <h1 class="text-2xl font-bold text-gray-800">Logistics Manager</h1>
          </div>

          <div class="px-4 pb-4">
            <.nav_link navigate={~p"/"} active={@active_nav == "dashboard"}>
              <Heroicons.home class="w-5 h-5 mr-3" /> Dashboard
            </.nav_link>

            <.nav_link navigate={~p"/organizations"} active={@active_nav == "organizations"}>
              <Heroicons.building_office class="w-5 h-5 mr-3" /> Organizations
            </.nav_link>

            <.nav_link navigate={~p"/accounts"} active={@active_nav == "accounts"}>
              <Heroicons.key class="w-5 h-5 mr-3" /> Accounts
            </.nav_link>

            <.nav_link navigate={~p"/branches"} active={@active_nav == "branches"}>
              <Heroicons.map_pin class="w-5 h-5 mr-3" /> Branches
            </.nav_link>

            <.nav_link navigate={~p"/users"} active={@active_nav == "users"}>
              <Heroicons.users class="w-5 h-5 mr-3" /> Users
            </.nav_link>
          </div>
        </nav>
        
    <!-- Main Content -->
        <main class="flex-1 p-8">
          <div class="flex justify-between items-center mb-8">
            <h2 class="text-3xl font-bold text-gray-900">Accounts</h2>
            <button
              phx-click="new_account"
              class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg font-medium transition-colors"
            >
              Add Account
            </button>
          </div>

          <%= if @show_form do %>
            <div class="bg-white rounded-lg shadow p-6 mb-8">
              <h3 class="text-xl font-semibold text-gray-900 mb-4">
                {if @selected_account, do: "Edit Account", else: "New Account"}
              </h3>

              <form phx-submit="save_account" class="space-y-4">
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Name</label>
                    <input
                      name="name"
                      value={@form[:name].value || ""}
                      class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-gray-900 bg-white"
                      required
                    />
                  </div>

                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Organization</label>
                    <select
                      name="organization_id"
                      class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-gray-900 bg-white"
                      required
                    >
                      <option value="">Select Organization</option>
                      <%= for org <- @organizations do %>
                        <option value={org.id} selected={@form[:organization_id].value == org.id}>
                          {org.name}
                        </option>
                      <% end %>
                    </select>
                  </div>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">API Key</label>
                    <input
                      name="api_key"
                      value={@form[:api_key].value || ""}
                      class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-gray-900 bg-white"
                      required
                    />
                  </div>

                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">API Secret</label>
                    <input
                      name="api_secret"
                      type="password"
                      value={@form[:api_secret].value || ""}
                      class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-gray-900 bg-white"
                      required
                    />
                  </div>
                </div>

                <div class="flex space-x-3">
                  <button
                    type="submit"
                    class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg font-medium transition-colors"
                  >
                    Save
                  </button>
                  <button
                    type="button"
                    phx-click="cancel_form"
                    class="bg-gray-300 hover:bg-gray-400 text-gray-700 px-4 py-2 rounded-lg font-medium transition-colors"
                  >
                    Cancel
                  </button>
                </div>
              </form>
            </div>
          <% end %>

          <div class="bg-white rounded-lg shadow overflow-hidden">
            <table class="min-w-full divide-y divide-gray-200">
              <thead class="bg-gray-50">
                <tr>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Name
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Organization
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    API Key
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Created
                  </th>
                  <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-gray-200">
                <%= for account <- @accounts do %>
                  <tr class="hover:bg-gray-50">
                    <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                      {account.name}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {account.organization.name}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 font-mono">
                      {String.slice(account.api_key, 0, 8)}...
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {Calendar.strftime(account.inserted_at, "%B %d, %Y")}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                      <button
                        phx-click="edit_account"
                        phx-value-id={account.id}
                        class="text-blue-600 hover:text-blue-900 mr-3"
                      >
                        Edit
                      </button>
                      <button
                        phx-click="delete_account"
                        phx-value-id={account.id}
                        class="text-red-600 hover:text-red-900"
                        data-confirm="Are you sure you want to delete this account?"
                      >
                        Delete
                      </button>
                    </td>
                  </tr>
                <% end %>
              </tbody>
            </table>
          </div>
        </main>
      </div>
    </LogisticsQuotesWeb.Layouts.app>
    """
  end

  attr :navigate, :string, required: true
  attr :active, :boolean, default: false
  slot :inner_block, required: true

  defp nav_link(assigns) do
    ~H"""
    <.link
      navigate={@navigate}
      class={[
        "flex items-center px-4 py-3 text-sm font-medium rounded-lg mb-1 transition-colors",
        if(@active, do: "bg-blue-100 text-blue-700", else: "text-gray-600 hover:bg-gray-100")
      ]}
    >
      {render_slot(@inner_block)}
    </.link>
    """
  end
end
