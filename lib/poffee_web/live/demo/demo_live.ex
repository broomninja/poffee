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

    <div class="mt-4 flex items-end justify-between">
      <.icon_button
        icon="tabler-trash-x"
        label="Login"
        color={:alert}
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
