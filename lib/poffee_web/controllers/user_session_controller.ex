defmodule PoffeeWeb.UserSessionController do
  use PoffeeWeb, :controller

  alias Poffee.Accounts
  alias Poffee.Constant
  alias PoffeeWeb.Router
  alias PoffeeWeb.UserAuth

  require Logger

  def create(conn, %{"_action" => "registered"} = params) do
    create(conn, params, "Account created successfully!")
  end

  def create(conn, %{"_action" => "password_updated"} = params) do
    params = put_in(params, ["user", "user_return_to"], ~p"/users/settings")

    conn
    |> create(params, "Password updated successfully!")
  end

  def create(conn, params) do
    create(conn, params, "Welcome back!")
  end

  defp create(conn, %{"user" => user_params}, info) do
    %{"email" => email, "password" => password} = user_params

    if user = Accounts.get_user_by_email_and_password(email, password) do
      conn
      |> put_flash(:info, info)
      |> UserAuth.log_in_user(user, user_params)
    else
      user_return_to = UserAuth.validate_return_to(user_params["user_return_to"])

      redirect_to =
        Router.Helpers.user_login_path(conn, :new, user_return_to: user_return_to || [])

      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      conn
      |> put_flash(:error, "Invalid email or password")
      |> put_flash(:email, String.slice(email, 0, Constant.email_max_length()))
      |> redirect(to: redirect_to)
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
