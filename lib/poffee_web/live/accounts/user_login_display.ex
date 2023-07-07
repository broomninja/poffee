defmodule PoffeeWeb.UserLoginDisplay do
  use PoffeeWeb, :html

  def show_user(assigns) do
    ~H"""
    <%= if @current_user do %>
      <Petal.Dropdown.dropdown js_lib="live_view_js">
        <:trigger_element>
          <div class="inline-flex items-center justify-center w-full align-middle focus:outline-none">
            <.tabler_icon name="tabler-user-cog" class="w-6 h-6" />
          </div>
        </:trigger_element>
        <Petal.Dropdown.dropdown_menu_item
          link_type="button"
          class="hover:bg-white font-semibold cursor-auto border-dotted border-b-2 border-gray-500"
        >
          <.tabler_icon name="tabler-user" /> <%= @current_user.email %>
        </Petal.Dropdown.dropdown_menu_item>
        <Petal.Dropdown.dropdown_menu_item
          link_type="live_redirect"
          to={~p"/users/settings"}
          label="Settings"
        />
        <Petal.Dropdown.dropdown_menu_item
          link_type="a"
          to={~p"/logout"}
          label="Sign out"
          method={:delete}
        />
      </Petal.Dropdown.dropdown>
    <% else %>
      <.tabler_icon_button
        icon="tabler-user"
        label="Login"
        bgcolor={:primary}
        iconcolor={:black}
        textcolor={:black}
        phx-click={show_modal("live-login-modal")}
        size={:auto}
      >
        Sign in
      </.tabler_icon_button>
    <% end %>
    """
  end
end
