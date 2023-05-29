defmodule PoffeeWeb.UserAuthLive do
  use PoffeeWeb, :verified_routes

  @moduledoc """
  Helpers for authenticating users in liveviews
  """
  alias Poffee.Accounts
  alias Poffee.Constant
  alias PoffeeWeb.UserAuth
  alias Phoenix.LiveView
  alias Phoenix.LiveView.Socket

  require Logger

  @doc """
  Handles mounting and authenticating the current_user in LiveViews.

  ## `on_mount` arguments

    * `:mount_current_user` - Assigns current_user
      to socket assigns based on user_token, or nil if
      there's no user_token or no matching user.

    * `:ensure_authenticated` - Authenticates the user from the session,
      and assigns the current_user to socket assigns based
      on user_token.
      Redirects to login page if there's no logged user.

    * `:redirect_if_user_is_authenticated` - Authenticates the user from the session.
      Redirects to signed_in_path if there's a logged user.

  ## Examples

  Use the `on_mount` lifecycle macro in LiveViews to mount or authenticate
  the current_user:

      defmodule PoffeeWeb.PageLive do
        use PoffeeWeb, :live_view

        on_mount {PoffeeWeb.UserAuth, :mount_current_user}
        ...
      end

  Or use the `live_session` of your router to invoke the on_mount callback:

      live_session :authenticated, on_mount: [{PoffeeWeb.UserAuth, :ensure_authenticated}] do
        live "/profile", ProfileLive, :index
      end
  """
  @spec on_mount(atom(), LiveView.unsigned_params(), map(), Socket.t()) ::
          {:cont, Socket.t()} | {:halt, Socket.t()}
  def on_mount(:mount_current_user, _params, session, socket) do
    {:cont, mount_current_user(session, socket)}
  end

  # def on_mount(:ensure_admin, _params, _session, %{assigns: %{current_user: user}} = socket) do

  def on_mount(:ensure_admin, _params, session, socket) do
    socket = mount_current_user(session, socket)
    current_user = socket.assigns.current_user
    Logger.debug("on_mount :ensure_admin: #{inspect(current_user, pretty: true)}")

    cond do
      Accounts.admin?(current_user) ->
        {:cont, socket}

      is_nil(current_user) ->
        {:halt, redirect_require_login(socket)}

      true ->
        {:halt, redirect_require_admin(socket)}
    end
  end

  def on_mount(:ensure_authenticated, _params, session, socket) do
    socket = mount_current_user(session, socket)

    if socket.assigns.current_user do
      {:cont, socket}
    else
      {:halt, redirect_require_login(socket)}
    end
  end

  def on_mount(:redirect_if_user_is_authenticated, _params, session, socket) do
    socket = mount_current_user(session, socket)

    if socket.assigns.current_user do
      {:halt, LiveView.redirect(socket, to: UserAuth.signed_in_path(socket))}
    else
      {:cont, socket}
    end
  end

  def on_mount(:skip_user_display, _params, _session, socket) do
    socket = Phoenix.Component.assign(socket, :skip_user_display, true)
    {:cont, socket}
  end

  @spec mount_current_user(map, Socket.t()) :: Socket.t()
  defp mount_current_user(session, socket) do
    Phoenix.Component.assign_new(socket, :current_user, fn ->
      if user_token = session["user_token"] do
        Accounts.get_user_by_session_token(user_token)
      end
    end)
  end

  @spec redirect_require_login(Socket.t()) :: Socket.t()
  defp redirect_require_login(socket) do
    socket
    |> LiveView.put_flash(:error, Constant.require_authenticated_text())
    # TODO: store_return_to?
    |> LiveView.redirect(to: ~p"/users/log_in")
  end

  @spec redirect_require_admin(Socket.t()) :: Socket.t()
  defp redirect_require_admin(socket) do
    socket
    |> LiveView.put_flash(:error, Constant.require_admin_text())
    |> LiveView.redirect(to: UserAuth.signed_in_path(socket))
  end
end
