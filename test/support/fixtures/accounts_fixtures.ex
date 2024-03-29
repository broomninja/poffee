defmodule Poffee.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Poffee.Accounts` context.
  """

  def unique_user_username, do: "user_username_#{:rand.uniform(99_999_999)}"
  def unique_admin_username, do: "admin_username_#{:rand.uniform(99_999_999)}"

  def unique_user_email, do: "user#{System.unique_integer()}@test.cc"
  def valid_user_password, do: "hello user!!!"

  def unique_admin_email, do: "admin#{System.unique_integer()}@test.cc"
  def valid_admin_password, do: "hello password!"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password(),
      username: unique_user_username()
    })
  end

  def valid_admin_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_admin_email(),
      password: valid_admin_password(),
      username: unique_admin_username()
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Poffee.Accounts.register_user()

    user
  end

  def admin_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_admin_attributes()
      |> Poffee.Accounts.register_admin()

    user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
