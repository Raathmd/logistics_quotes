defmodule LogisticsQuotesWeb.OrganizationsLive do
  use LogisticsQuotesWeb, :live_view
  alias LogisticsQuotes.Organizations.Organization

  def mount(_params, _session, socket) do
    organizations = Ash.read!(Organization)

    {:ok,
     socket
     |> assign(:page_title, "Organizations")
     |> assign(:active_nav, "organizations")
     |> assign(:organizations, organizations)
     |> assign(:show_form, false)
     |> assign(:selected_organization, nil)
     |> assign(:form, to_form(%{}))}
  end

  def handle_event("new_organization", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_form, true)
     |> assign(:selected_organization, nil)
     |> assign(:form, to_form(%{}))}
  end

  def handle_event("edit_organization", %{"id" => id}, socket) do
    organization = Ash.get!(Organization, id)

    form_data = %{
      "name" => organization.name,
      "description" => organization.description
    }

    {:noreply,
     socket
     |> assign(:show_form, true)
     |> assign(:selected_organization, organization)
     |> assign(:form, to_form(form_data))}
  end

  def handle_event("cancel_form", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_form, false)
     |> assign(:selected_organization, nil)
     |> assign(:form, to_form(%{}))}
  end

  def handle_event("save_organization", %{"name" => name, "description" => description}, socket) do
    attrs = %{name: name, description: description}

    result =
      if socket.assigns.selected_organization do
        Ash.update!(socket.assigns.selected_organization, attrs)
      else
        Ash.create!(Organization, attrs)
      end

    organizations = Ash.read!(Organization)

    {:noreply,
     socket
     |> assign(:organizations, organizations)
     |> assign(:show_form, false)
     |> assign(:selected_organization, nil)
     |> assign(:form, to_form(%{}))
     |> put_flash(:info, "Organization saved successfully")}
  end

  def handle_event("delete_organization", %{"id" => id}, socket) do
    organization = Ash.get!(Organization, id)
    Ash.destroy!(organization)
    organizations = Ash.read!(Organization)

    {:noreply,
     socket
     |> assign(:organizations, organizations)
     |> put_flash(:info, "Organization deleted successfully")}
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
            <h2 class="text-3xl font-bold text-gray-900">Organizations</h2>
            <button
              phx-click="new_organization"
              class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg font-medium transition-colors"
            >
              Add Organization
            </button>
          </div>

          <%= if @show_form do %>
            <div class="bg-white rounded-lg shadow p-6 mb-8">
              <h3 class="text-xl font-semibold text-gray-900 mb-4">
                {if @selected_organization, do: "Edit Organization", else: "New Organization"}
              </h3>

              <form phx-submit="save_organization" class="space-y-4">
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
                  <label class="block text-sm font-medium text-gray-700 mb-1">Description</label>
                  <textarea
                    name="description"
                    rows="3"
                    class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-gray-900 bg-white"
                  >{@form[:description].value || ""}</textarea>
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
                    Description
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
                <%= for org <- @organizations do %>
                  <tr class="hover:bg-gray-50">
                    <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                      {org.name}
                    </td>
                    <td class="px-6 py-4 text-sm text-gray-500">
                      {org.description}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {Calendar.strftime(org.inserted_at, "%B %d, %Y")}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                      <button
                        phx-click="edit_organization"
                        phx-value-id={org.id}
                        class="text-blue-600 hover:text-blue-900 mr-3"
                      >
                        Edit
                      </button>
                      <button
                        phx-click="delete_organization"
                        phx-value-id={org.id}
                        class="text-red-600 hover:text-red-900"
                        data-confirm="Are you sure you want to delete this organization?"
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
