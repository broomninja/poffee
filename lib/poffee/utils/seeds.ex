defmodule Poffee.Seeds do
  alias Poffee.Accounts

  require Logger

  def run do
    Logger.debug("[Seeds.run()] Started for #{Mix.env()} env.")
    seed(Mix.env())
    Logger.debug("[Seeds.run()] Finished.")
  end

  # dev only seeds
  def seed(env) when env in [:dev, :test] do
    admin_attr = %{
      username: "admin_1",
      email: "admin@test.cc",
      password: "12341234"
    }

    with {:error, changeset} <- Accounts.register_admin(admin_attr) do
      Logger.info("Error running seeds: #{inspect(admin_attr)} #{inspect(changeset.errors)}")
    end

    user_attr = %{
      username: "bob1",
      email: "bob@test.cc",
      password: "12341234"
    }

    with {:error, changeset} <- Accounts.register_user(user_attr) do
      Logger.info("Error running seeds: #{inspect(user_attr)} #{inspect(changeset.errors)}")
    end
  end

  # prod only seeds
  def seed(:prod) do
  end

  # common seeds for all env
  def seed(_) do
  end
end
