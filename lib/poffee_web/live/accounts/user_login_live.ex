defmodule PoffeeWeb.UserLoginLive do
  use PoffeeWeb, :live_view

  require Logger

  @impl Phoenix.LiveView
  def mount(:not_mounted_at_router = _params, session, socket) do
    mount(%{user_return_to: nil}, session, socket)
  end

  @doc """
  When current_uri is set in the session, we will use that to override the user_return_to in params.
  This is only used when we have a modal login (child liveview) but we cannot pass user_return_to 
  to the child liveview via live_render.

  Example:

    <.modal id="live-login-modal" on_cancel={hide_modal("live-login-modal")}>
      <%= live_render(@socket, PoffeeWeb.UserLoginLive, id: "login", session: %{"current_uri" => assigns[:current_uri]}) %>  
    </.modal>
  """
  def mount(_params, %{"current_uri" => current_uri} = session, socket) do
    mount(%{"user_return_to" => current_uri}, Map.delete(session, "current_uri"), socket)
  end

  def mount(params, _session, socket) do
    email = live_flash(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    user_return_to = Map.get(params, "user_return_to")

    {:ok, assign(socket, form: form, user_return_to: user_return_to),
     temporary_assigns: [form: form]}
  end
end
