defmodule Poffee.Seeds do
  alias Poffee.Accounts

  require Logger

  def run do
    Logger.debug("[Seeds.run()] Started for #{Mix.env()} env.")
    common()
    seed(Mix.env())
    Logger.debug("[Seeds.run()] Finished.")
  end

  # dev only seeds
  defp seed(env) when env in [:dev, :test] do
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

    user_attr = %{
      username: "cat_123",
      email: "cat@test.cc",
      password: "12341234"
    }

    with {:error, changeset} <- Accounts.register_user(user_attr) do
      Logger.info("Error running seeds: #{inspect(user_attr)} #{inspect(changeset.errors)}")
    end
  end

  # prod only seeds
  defp seed(:prod) do
  end

  # common seeds for all env
  defp common do
  end
end
