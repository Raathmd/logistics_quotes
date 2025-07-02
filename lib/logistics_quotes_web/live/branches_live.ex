defmodule LogisticsQuotesWeb.BranchesLive do
  use LogisticsQuotesWeb, :live_view
  alias LogisticsQuotes.Branches.Branch
  alias LogisticsQuotes.Accounts.Account

  def mount(_params, _session, socket) do
    branches = Ash.read!(Branch, load: [:account])
    accounts = Ash.read!(Account, load: [:organization])

    {:ok,
     socket
     |> assign(:page_title, "Branches")
     |> assign(:active_nav, "branches")
     |> assign(:branches, branches)
     |> assign(:accounts, accounts)
     |> assign(:show_form, false)
     |> assign(:selected_branch, nil)
     |> assign(:form, to_form(%{}))}
  end

  def handle_event("new_branch", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_form, true)
     |> assign(:selected_branch, nil)
     |> assign(:form, to_form(%{}))}
  end

  def handle_event("edit_branch", %{"id" => id}, socket) do
    branch = Ash.get!(Branch, id, load: [:account])

    form_data = %{
      "name" => branch.name,
      "contact_person" => branch.contact_person,
      "phone" => branch.phone,
      "email" => branch.email,
      "address" => branch.address,
      "suburb" => branch.suburb,
      "city" => branch.city,
      "postal_code" => branch.postal_code,
      "account_id" => branch.account_id
    }

    {:noreply,
     socket
     |> assign(:show_form, true)
     |> assign(:selected_branch, branch)
     |> assign(:form, to_form(form_data))}
  end

  def handle_event("cancel_form", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_form, false)
     |> assign(:selected_branch, nil)
     |> assign(:form, to_form(%{}))}
  end

  def handle_event(
        "save_branch",
        %{
          "name" => name,
          "contact_person" => contact_person,
          "phone" => phone,
          "email" => email,
          "address" => address,
          "suburb" => suburb,
          "city" => city,
          "postal_code" => postal_code,
          "account_id" => account_id
        },
        socket
      ) do
    attrs = %{
      name: name,
      contact_person: contact_person,
      phone: phone,
      email: email,
      address: address,
      suburb: suburb,
      city: city,
      postal_code: postal_code,
      account_id: account_id
    }

    result =
      if socket.assigns.selected_branch do
        Ash.update!(socket.assigns.selected_branch, attrs)
      else
        Ash.create!(Branch, attrs)
      end

    branches = Ash.read!(Branch, load: [:account])

    {:noreply,
     socket
     |> assign(:branches, branches)
     |> assign(:show_form, false)
     |> assign(:selected_branch, nil)
     |> assign(:form, to_form(%{}))
     |> put_flash(:info, "Branch saved successfully")}
  end

  def handle_event("delete_branch", %{"id" => id}, socket) do
    branch = Ash.get!(Branch, id)
    Ash.destroy!(branch)
    branches = Ash.read!(Branch, load: [:account])

    {:noreply,
     socket
     |> assign(:branches, branches)
     |> put_flash(:info, "Branch deleted successfully")}
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
            <h2 class="text-3xl font-bold text-gray-900">Branches</h2>
            <button
              phx-click="new_branch"
              class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg font-medium transition-colors"
            >
              Add Branch
            </button>
          </div>

          <%= if @show_form do %>
            <div class="bg-white rounded-lg shadow p-6 mb-8">
              <h3 class="text-xl font-semibold text-gray-900 mb-4">
                {if @selected_branch, do: "Edit Branch", else: "New Branch"}
              </h3>

              <form phx-submit="save_branch" class="space-y-4">
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
                    <label class="block text-sm font-medium text-gray-700 mb-1">Account</label>
                    <select
                      name="account_id"
                      class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-gray-900 bg-white"
                      required
                    >
                      <option value="">Select Account</option>
                      <%= for account <- @accounts do %>
                        <option value={account.id} selected={@form[:account_id].value == account.id}>
                          {account.name} ({account.organization.name})
                        </option>
                      <% end %>
                    </select>
                  </div>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Contact Person</label>
                    <input
                      name="contact_person"
                      value={@form[:contact_person].value || ""}
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
                  <label class="block text-sm font-medium text-gray-700 mb-1">Address</label>
                  <input
                    name="address"
                    value={@form[:address].value || ""}
                    class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-gray-900 bg-white"
                    required
                  />
                </div>

                <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Suburb</label>
                    <input
                      name="suburb"
                      value={@form[:suburb].value || ""}
                      class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-gray-900 bg-white"
                      required
                    />
                  </div>

                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">City</label>
                    <input
                      name="city"
                      value={@form[:city].value || ""}
                      class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-gray-900 bg-white"
                      required
                    />
                  </div>

                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Postal Code</label>
                    <input
                      name="postal_code"
                      value={@form[:postal_code].value || ""}
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
                    Account
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Contact
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Location
                  </th>
                  <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-gray-200">
                <%= for branch <- @branches do %>
                  <tr class="hover:bg-gray-50">
                    <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                      {branch.name}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {branch.account.name}
                    </td>
                    <td class="px-6 py-4 text-sm text-gray-500">
                      <div>{branch.contact_person}</div>
                      <div class="text-xs text-gray-400">{branch.phone}</div>
                    </td>
                    <td class="px-6 py-4 text-sm text-gray-500">
                      <div>{branch.city}, {branch.suburb}</div>
                      <div class="text-xs text-gray-400">{branch.postal_code}</div>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                      <button
                        phx-click="edit_branch"
                        phx-value-id={branch.id}
                        class="text-blue-600 hover:text-blue-900 mr-3"
                      >
                        Edit
                      </button>
                      <button
                        phx-click="delete_branch"
                        phx-value-id={branch.id}
                        class="text-red-600 hover:text-red-900"
                        data-confirm="Are you sure you want to delete this branch?"
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
