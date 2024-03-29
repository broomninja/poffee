defmodule PoffeeWeb.UserAuth do
  use PoffeeWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  alias Poffee.Accounts
  alias Poffee.Accounts.User
  alias Poffee.Constant
  alias Poffee.Utils

  require Logger

  # Make the remember me cookie valid for 60 days.
  # If you want bump or reduce this value, also change
  # the token expiry itself in UserToken.
  @max_age 60 * 60 * 24 * 60
  @remember_me_cookie "_pineapple_login_web_user_remember_me"
  @remember_me_options [sign: true, max_age: @max_age, same_site: "Lax"]

  @doc """
  Logs the user in.

  It renews the session ID and clears the whole session
  to avoid fixation attacks. See the renew_session
  function to customize this behaviour.

  It also sets a `:live_socket_id` key in the session,
  so LiveView sessions are identified and automatically
  disconnected on log out. The line can be safely removed
  if you are not using LiveView.
  """
  @spec log_in_user(Plug.Conn.t(), User.t(), map()) :: Plug.Conn.t()
  def log_in_user(conn, user, params \\ %{}) do
    token = Accounts.generate_user_session_token(user)

    conn
    |> renew_session()
    |> put_token_in_session(token)
    |> write_remember_me_cookie(token, params)
    |> redirect_user_after_login(params)
  end

  @doc """
  Returns to the previous page or redirects to home.
  """
  def redirect_user_after_login(conn, params \\ %{}) do
    redirect_to = validate_return_to(params["user_return_to"], signed_in_path(conn))

    conn
    |> unsafe_redirect(to: redirect_to)
  end

  # defp maybe_write_remember_me_cookie(conn, token, %{"remember_me" => "true"}) do
  #   put_resp_cookie(conn, @remember_me_cookie, token, @remember_me_options)
  # end
  # defp maybe_write_remember_me_cookie(conn, _token, _params) do
  #   conn
  # end

  # We will always use remember_me cookie
  defp write_remember_me_cookie(conn, token, _params) do
    put_resp_cookie(conn, @remember_me_cookie, token, @remember_me_options)
  end

  # This function renews the session ID and erases the whole
  # session to avoid fixation attacks. If there is any data
  # in the session you may want to preserve after log in/log out,
  # you must explicitly fetch the session data before clearing
  # and then immediately set it after clearing, for example:
  #
  #     defp renew_session(conn) do
  #       preferred_locale = get_session(conn, :preferred_locale)
  #
  #       conn
  #       |> configure_session(renew: true)
  #       |> clear_session()
  #       |> put_session(:preferred_locale, preferred_locale)
  #     end
  #
  defp renew_session(conn) do
    conn
    |> configure_session(renew: true)
    |> clear_session()
  end

  @doc """
  Logs the user out.

  It clears all session data for safety. See renew_session.
  """
  @spec log_out_user(Plug.Conn.t()) :: Plug.Conn.t()
  def log_out_user(conn) do
    user_token = get_session(conn, :user_token)
    user_token && Accounts.delete_user_session_token(user_token)

    if live_socket_id = get_session(conn, :live_socket_id) do
      PoffeeWeb.Endpoint.broadcast(live_socket_id, "disconnect", %{})
    end

    conn
    |> renew_session()
    |> delete_resp_cookie(@remember_me_cookie)
    |> unsafe_redirect(to: ~p"/")
  end

  @doc """
  Authenticates the user by looking into the session
  and remember me token.
  """
  @spec fetch_current_user(Plug.Conn.t(), Keyword.t()) :: Plug.Conn.t()
  def fetch_current_user(conn, _opts) do
    {user_token, conn} = ensure_user_token(conn)
    user = user_token && Accounts.get_user_by_session_token(user_token)
    assign(conn, :current_user, user)
  end

  defp ensure_user_token(conn) do
    if token = get_session(conn, :user_token) do
      {token, conn}
    else
      conn = fetch_cookies(conn, signed: [@remember_me_cookie])

      if token = conn.cookies[@remember_me_cookie] do
        {token, put_token_in_session(conn, token)}
      else
        {nil, conn}
      end
    end
  end

  @doc """
  Used for routes that require the user to not be authenticated.
  """
  @spec redirect_if_user_is_authenticated(Plug.Conn.t(), Keyword.t()) :: Plug.Conn.t()
  def redirect_if_user_is_authenticated(conn, _opts) do
    if conn.assigns[:current_user] do
      redirect_to = validate_return_to(conn.query_params["user_return_to"], signed_in_path(conn))

      conn
      |> unsafe_redirect(to: redirect_to)
      |> halt()
    else
      conn
    end
  end

  @doc """
  Used for routes that require the user to be authenticated.

  If you want to enforce the user email is confirmed before
  they use the application at all, here would be a good place.
  """
  @spec require_authenticated_user(Plug.Conn.t(), Keyword.t()) :: Plug.Conn.t()
  def require_authenticated_user(%{assigns: %{current_user: user}} = conn, _opts)
      when not is_nil(user) do
    conn
  end

  def require_authenticated_user(conn, _opts) do
    return_to_param = current_path(conn)
    redirect_to = Routes.user_login_path(conn, :new, user_return_to: return_to_param)

    # Logger.debug("[require_authenticated_user] redirect to = #{redirect_to}")

    conn
    |> put_flash(:warn, Constant.require_authenticated_text())
    |> unsafe_redirect(to: redirect_to)
    |> halt()
  end

  @doc """
  Used for routes that require the user to have an admin role.

  """
  @spec require_authenticated_admin(Plug.Conn.t(), Keyword.t()) :: Plug.Conn.t()
  def require_authenticated_admin(%{assigns: %{current_user: user}} = conn, _opts)
      when not is_nil(user) do
    if Accounts.admin?(user) do
      conn
    else
      conn
      |> put_flash(:warn, Constant.require_admin_text())
      |> unsafe_redirect(to: signed_in_path(conn))
      |> halt()
    end
  end

  def require_authenticated_admin(conn, _opts) do
    return_to_param = current_path(conn)
    redirect_to = Routes.user_login_path(conn, :new, user_return_to: return_to_param)

    conn
    |> put_flash(:warn, Constant.require_authenticated_text())
    |> unsafe_redirect(to: redirect_to)
    |> halt()
  end

  defp put_token_in_session(conn, token) do
    conn
    |> put_session(:user_token, token)
    |> put_session(:live_socket_id, "users_sessions:#{Base.url_encode64(token)}")
  end

  # defp maybe_store_return_to(%{method: "GET"} = conn) do
  #   put_session(conn, :user_return_to, current_path(conn))
  # end
  # defp maybe_store_return_to(conn), do: conn

  def validate_return_to(return_to, default_value \\ nil) do
    # Logger.debug(
    #   "[validate_return_to] return_to = #{return_to}, default_value = #{default_value}"
    # )

    if Utils.valid_local_url?(return_to) do
      return_to
    else
      default_value
    end
  end

  def signed_in_path(_conn), do: ~p"/"

  # TODO: remove this block after the following two issues are properly resolved:
  # https://github.com/phoenixframework/phoenix/pull/5482
  # https://github.com/phoenixframework/phoenix/issues/5508
  defp unsafe_redirect(conn, opts) do
    url = opts[:to]
    html = Plug.HTML.html_escape(url)
    body = "<html><body>You are being <a href=\"#{html}\">redirected</a>.</body></html>"

    conn
    |> put_resp_header("location", url)
    |> send_resp(conn.status || 302, "text/html", body)
  end

  defp send_resp(conn, default_status, default_content_type, body) do
    conn
    |> ensure_resp_content_type(default_content_type)
    |> send_resp(conn.status || default_status, body)
  end

  defp ensure_resp_content_type(%Plug.Conn{resp_headers: resp_headers} = conn, content_type) do
    if List.keyfind(resp_headers, "content-type", 0) do
      conn
    else
      content_type = content_type <> "; charset=utf-8"
      %Plug.Conn{conn | resp_headers: [{"content-type", content_type} | resp_headers]}
    end
  end

  # END TODO remove
end
