defmodule LogisticsQuotesWeb.UsersLive do
  use LogisticsQuotesWeb, :live_view
  alias LogisticsQuotes.Users.User
  alias LogisticsQuotes.Organizations.Organization
  alias LogisticsQuotes.Branches.Branch

  def mount(_params, _session, socket) do
    users = Ash.read!(User, load: [:organization, :branch])
    organizations = Ash.read!(Organization)
    branches = Ash.read!(Branch, load: [:account])

    {:ok,
     socket
     |> assign(:page_title, "Users")
     |> assign(:active_nav, "users")
     |> assign(:users, users)
     |> assign(:organizations, organizations)
     |> assign(:branches, branches)
     |> assign(:show_form, false)
     |> assign(:selected_user, nil)
     |> assign(:form, to_form(%{}))}
  end

  def handle_event("new_user", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_form, true)
     |> assign(:selected_user, nil)
     |> assign(:form, to_form(%{}))}
  end

  def handle_event("edit_user", %{"id" => id}, socket) do
    user = Ash.get!(User, id, load: [:organization, :branch])

    form_data = %{
      "first_name" => user.first_name,
      "last_name" => user.last_name,
      "email" => user.email,
      "phone" => user.phone,
      "role" => user.role,
      "organization_id" => user.organization_id,
      "branch_id" => user.branch_id
    }

    {:noreply,
     socket
     |> assign(:show_form, true)
     |> assign(:selected_user, user)
     |> assign(:form, to_form(form_data))}
  end

  def handle_event("cancel_form", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_form, false)
     |> assign(:selected_user, nil)
     |> assign(:form, to_form(%{}))}
  end

  def handle_event(
        "save_user",
        %{
          "first_name" => first_name,
          "last_name" => last_name,
          "email" => email,
          "phone" => phone,
          "role" => role,
          "organization_id" => org_id,
          "branch_id" => branch_id
        },
        socket
      ) do
    attrs = %{
      first_name: first_name,
      last_name: last_name,
      email: email,
      phone: phone,
      role: role,
      organization_id: org_id,
      branch_id: if(branch_id == "", do: nil, else: branch_id)
    }

    result =
      if socket.assigns.selected_user do
        Ash.update!(socket.assigns.selected_user, attrs)
      else
        Ash.create!(User, attrs)
      end

    users = Ash.read!(User, load: [:organization, :branch])

    {:noreply,
     socket
     |> assign(:users, users)
     |> assign(:show_form, false)
     |> assign(:selected_user, nil)
     |> assign(:form, to_form(%{}))
     |> put_flash(:info, "User saved successfully")}
  end

  def handle_event("delete_user", %{"id" => id}, socket) do
    user = Ash.get!(User, id)
    Ash.destroy!(user)
    users = Ash.read!(User, load: [:organization, :branch])

    {:noreply,
     socket
     |> assign(:users, users)
     |> put_flash(:info, "User deleted successfully")}
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
            <h2 class="text-3xl font-bold text-gray-900">Users</h2>
            <button
              phx-click="new_user"
              class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg font-medium transition-colors"
            >
              Add User
            </button>
          </div>

          <%= if @show_form do %>
            <div class="bg-white rounded-lg shadow p-6 mb-8">
              <h3 class="text-xl font-semibold text-gray-900 mb-4">
                {if @selected_user, do: "Edit User", else: "New User"}
              </h3>

              <form phx-submit="save_user" class="space-y-4">
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">First Name</label>
                    <input
                      name="first_name"
                      value={@form[:first_name].value || ""}
                      class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-gray-900 bg-white"
                      required
                    />
                  </div>

                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Last Name</label>
                    <input
                      name="last_name"
                      value={@form[:last_name].value || ""}
                      class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-gray-900 bg-white"
                      required
                    />
                  </div>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Email</label>
                    <input
                      name="email"
                      type="email"
                      value={@form[:email].value || ""}
                      class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-gray-900 bg-white"
                      required
                    />
                  </div>

                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Phone</label>
                    <input
                      name="phone"
                      value={@form[:phone].value || ""}
                      class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-gray-900 bg-white"
                      required
                    />
                  </div>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Role</label>
                    <select
                      name="role"
                      class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-gray-900 bg-white"
                      required
                    >
                      <option value="">Select Role</option>
                      <option value="admin" selected={@form[:role].value == "admin"}>Admin</option>
                      <option value="user" selected={@form[:role].value == "user"}>User</option>
                      <option value="viewer" selected={@form[:role].value == "viewer"}>Viewer</option>
                    </select>
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

                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">
                      Branch (Optional)
                    </label>
                    <select
                      name="branch_id"
                      class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-gray-900 bg-white"
                    >
                      <option value="">No Branch Assignment</option>
                      <%= for branch <- @branches do %>
                        <option value={branch.id} selected={@form[:branch_id].value == branch.id}>
                          {branch.name} ({branch.account.name})
                        </option>
                      <% end %>
                    </select>
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
                    Email
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Role
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Organization
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Branch
                  </th>
                  <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-gray-200">
                <%= for user <- @users do %>
                  <tr class="hover:bg-gray-50">
                    <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                      {user.first_name} {user.last_name}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {user.email}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      <span class={[
                        "inline-flex px-2 py-1 text-xs font-semibold rounded-full",
                        case user.role do
                          "admin" -> "bg-red-100 text-red-800"
                          "user" -> "bg-blue-100 text-blue-800"
                          "viewer" -> "bg-gray-100 text-gray-800"
                          _ -> "bg-gray-100 text-gray-800"
                        end
                      ]}>
                        {String.capitalize(user.role)}
                      </span>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {user.organization.name}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {if user.branch, do: user.branch.name, else: "—"}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                      <button
                        phx-click="edit_user"
                        phx-value-id={user.id}
                        class="text-blue-600 hover:text-blue-900 mr-3"
                      >
                        Edit
                      </button>
                      <button
                        phx-click="delete_user"
                        phx-value-id={user.id}
                        class="text-red-600 hover:text-red-900"
                        data-confirm="Are you sure you want to delete this user?"
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
