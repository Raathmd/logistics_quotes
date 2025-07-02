defmodule LogisticsQuotesWeb.DashboardLive do
  use LogisticsQuotesWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Dashboard")
     |> assign(:active_nav, "dashboard")}
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
          <h2 class="text-3xl font-bold text-gray-900 mb-8">Dashboard Overview</h2>

          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
            <.stat_card title="Organizations" value="Loading..." icon="building-office" />
            <.stat_card title="Accounts" value="Loading..." icon="key" />
            <.stat_card title="Branches" value="Loading..." icon="map-pin" />
            <.stat_card title="Users" value="Loading..." icon="users" />
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

  attr :title, :string, required: true
  attr :value, :string, required: true
  attr :icon, :string, required: true

  defp stat_card(assigns) do
    ~H"""
    <div class="bg-white rounded-lg shadow p-6">
      <div class="flex items-center">
        <div class="flex-shrink-0">
          <div class="w-8 h-8 bg-blue-100 rounded-lg flex items-center justify-center">
            <Heroicons.building_office class="w-5 h-5 text-blue-600" />
          </div>
        </div>
        <div class="ml-4">
          <p class="text-sm font-medium text-gray-600">{@title}</p>
          <p class="text-2xl font-semibold text-gray-900">{@value}</p>
        </div>
      </div>
    </div>
    """
  end
end
