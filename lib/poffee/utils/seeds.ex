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

  defp create_brand_pages_and_feedbacks do
    user_bob = Accounts.get_user_by_email("bob@test.cc")
    user_cat = Accounts.get_user_by_email("cat@test.cc")

    if is_nil(Social.get_brand_page_with_feedbacks_by_user(user_bob)) do
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
        %{content: "first feedback content from Cat", title: "Cat's first feedback "}
        |> Social.create_feedback(user_cat, brandpage_bob)
    end

    if is_nil(Social.get_brand_page_with_feedbacks_by_user(user_cat)) do
      {:ok, brandpage_cat} =
        %{
          title: "Cat's Brand Page",
          description: "This should not be visible to the public.",
          status: :brand_page_status_private
        }
        |> Social.create_brand_page(user_cat)

      {:ok, _fb4} =
        %{content: "second feedback content from Cat", title: "Cat's second feedback "}
        |> Social.create_feedback(user_cat, brandpage_cat)
    end
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
      %{username: "cat_123", email: "cat@test.cc", password: "12341234"},
      %{username: "dave33", email: "dave@test.cc", password: "12341234"}
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
end
