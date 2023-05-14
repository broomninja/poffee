defmodule PoffeeWeb.DemoLive do
  use PoffeeWeb, :live_view

  def render(assigns) do
    ~H"""
    <%!-- <.form for={:form} action={~p"/submit"} phx-change="validate">
      <button type="submit">Submit</button>
    </.form> --%>
    <a href="/">Home</a>
    <a href="/">
      <img src={~p"/images/logo.svg"} width="36" />
    </a>
    <div class="" style="display: inline-flex; transform-style: preserve-3d">
      Hero: <.icon name="hero-arrow-top-right-on-square-solid" class="h-6 w-6 animate-spin " />
    </div>

    <span class="" style="display: inline-flex; transform-style: preserve-3d">
      Tabler: <.tabler_icon name="tabler-refresh" class="ml-1 w-8 h-8 animate-spin " />
    </span>

    <span class="" style="display: inline-flex; transform-style: preserve-3d">
      Tabler: <.tabler_icon name="tabler-abc" class="ml-1 w-10 h-10 animate-spin" />
    </span>

    <%= if @current_user do %>
      Welcome
    <% else %>
      <div class="mt-4 flex items-end justify-between">
        <.tabler_icon_button
          icon="tabler-trash-x"
          label="Login"
          color={:warning}
          phx-click={show_modal("login-modal")}
          size={:md}
        />
      </div>

      <.modal id="login-modal" on_cancel={hide_modal("login-modal")}>
        <%= live_render(@socket, PoffeeWeb.UserLoginLive, id: "login") %>
      </.modal>
    <% end %>
    """
  end

  def handle_event("validate", _changes, socket) do
    {:noreply, socket}
  end
end
