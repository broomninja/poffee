defmodule Poffee.Seeds do
  alias Poffee.Accounts

  require Logger

  def run do
    Logger.debug("[Seeds.run()] Started for #{Mix.env()} env.")
    common()
    seed(Mix.env())
    Logger.debug("[Seeds.run()] Finished.")
  end

  # common seeds for all env
  defp common do
  end

  # prod only seeds
  defp seed(:prod) do
    IO.warn("Remove following seed before production release")
    seed(:dev)
  end

  # dev only seeds
  defp seed(env) when env in [:dev, :test] do
    create_users(env)
    create_brand_pages()
    create_feedbacks()
  end

  defp create_brand_pages do
    user = Accounts.get_user_by_email("bob@test.cc")
  end

  defp create_feedbacks do
  end

  defp create_users(env) do
    admin_attr = %{
      username: "admin_1",
      email: "admin@test.cc",
      password: "12341234"
    }

    with {:error, changeset} <- Accounts.register_admin(admin_attr) do
      if env != :test do
        Logger.error("Error running seeds: #{inspect(admin_attr)} #{inspect(changeset.errors)}")
      end
    end

    user_attr = %{
      username: "bob1",
      email: "bob@test.cc",
      password: "12341234"
    }

    with {:error, changeset} <- Accounts.register_user(user_attr) do
      Logger.warn("Error running seeds: #{inspect(user_attr)} #{inspect(changeset.errors)}")
    end

    user_attr = %{
      username: "cat_123",
      email: "cat@test.cc",
      password: "12341234"
    }

    with {:error, changeset} <- Accounts.register_user(user_attr) do
      if env != :test do
        Logger.error("Error running seeds: #{inspect(user_attr)} #{inspect(changeset.errors)}")
      end
    end
  end
end
