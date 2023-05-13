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
    <div class="">
      Hero: <.icon name="hero-phone-x-mark-solid" class="h-6 w-6 animate-spin  preserve-3d" />
    </div>

    <span class="">
      Tabler: <.tabler_icon name="tabler-refresh" class="ml-1 w-8 h-8 animate-spin preserve-3d " />
    </span>

    <span class="" style="display: inline-flex; transform-style: preserve">
      Tabler: <.tabler_icon name="tabler-abc" class="ml-1 w-10 h-10 animate-spin preserve-3d" />
    </span>

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
      <.header>
        Login
        <:subtitle>
          Please sign in
        </:subtitle>
      </.header>
    </.modal>
    """
  end

  def handle_event("validate", _changes, socket) do
    {:noreply, socket}
  end
end
