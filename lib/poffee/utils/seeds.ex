defmodule Poffee.Seeds do
  alias Poffee.Accounts
  alias Poffee.Social

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
    IO.warn("Seeding for demo purposes, please remove before production release")
    seed(:dev)
  end

  # dev/test only seeds
  defp seed(env) when env in [:dev, :test] do
    create_users(env)
    create_brand_pages_and_feedbacks()
  end

  defp create_users(env) do
    admin_attr = %{
      username: "admin_1",
      email: "admin@test.cc",
      password: "12341234"
    }

    if is_nil(Accounts.get_user_by_email(admin_attr.email)) do
      with {:error, changeset} <- Accounts.register_admin(admin_attr) do
        if env != :test do
          Logger.error("Error running seeds: #{inspect(admin_attr)} #{inspect(changeset.errors)}")
        end
      end
    end

    [
      %{username: "bob1", email: "bob@test.cc", password: "12341234"},
      %{username: "cara_123", email: "cara@test.cc", password: "12341234"},
      %{username: "dave3371", email: "dave@test.cc", password: "12341234"},
      %{username: "eve__11", email: "eve@test.cc", password: "12341234"},
      %{username: "fred991", email: "fred@test.cc", password: "12341234"},
      %{username: "greg_13", email: "greg@test.cc", password: "12341234"},
      %{username: "henry_19190922", email: "henry@test.cc", password: "12341234"},
      %{username: "iris_15", email: "iris@test.cc", password: "12341234"},
      %{username: "jay_31", email: "jay@test.cc", password: "12341234"},
      %{username: "kay7120", email: "kay@test.cc", password: "12341234"}
    ]
    |> Enum.map(fn user_attr ->
      if is_nil(Accounts.get_user_by_email(user_attr.email)) do
        with {:error, changeset} <- Accounts.register_user(user_attr) do
          if env != :test do
            Logger.warn("Error running seeds: #{inspect(user_attr)} #{inspect(changeset.errors)}")
          end
        end
      end
    end)
  end

  defp create_brand_pages_and_feedbacks do
    user_bob = Accounts.get_user_by_email("bob@test.cc")
    user_cara = Accounts.get_user_by_email("cara@test.cc")

    if is_nil(Social.get_brand_page_by_user(user_bob)) do
      {:ok, brandpage_bob} =
        %{title: "Bob's Brand Page", description: "I love feedbacks from our fans."}
        |> Social.create_brand_page(user_bob)

      {:ok, _fb1} =
        %{content: "first feedback content from Bob", title: "Bob's first feedback"}
        |> Social.create_feedback(user_bob, brandpage_bob)

      {:ok, _fb2} =
        %{
          content: "second feedback content from Bob",
          title: "Bob's second feedback - NOW REMOVED",
          status: :feedback_status_removed
        }
        |> Social.create_feedback(user_bob, brandpage_bob)

      {:ok, _fb3} =
        %{content: "first feedback content from Cara", title: "Cara's first feedback "}
        |> Social.create_feedback(user_cara, brandpage_bob)
    end

    if is_nil(Social.get_brand_page_by_user(user_cara)) do
      {:ok, brandpage_cara} =
        %{
          title: "Cara's Brand Page",
          description: "This should not be visible to the public.",
          status: :brand_page_status_private
        }
        |> Social.create_brand_page(user_cara)

      {:ok, _fb4} =
        %{content: "second feedback content from Cara", title: "Cara's second feedback "}
        |> Social.create_feedback(user_cara, brandpage_cara)
    end
  end
end
