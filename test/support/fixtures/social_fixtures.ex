defmodule Poffee.SocialFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Poffee.Social` context.
  """

  @doc """
  Generate a feedback.
  """
  def feedback_fixture(user, brand_page, attrs \\ %{}) do
    {:ok, feedback} =
      attrs
      |> Enum.into(%{
        content: "default content",
        title: "default title",
        author_id: user.id,
        brand_page_id: brand_page.id
      })
      |> Poffee.Social.create_feedback()

    feedback
  end

  @doc """
  Generate a brand_page.
  """
  def brand_page_fixture(user, attrs \\ %{}) do
    # IO.inspect(user, label: "brand_page_fixture")

    {:ok, brand_page} =
      attrs
      |> Enum.into(%{
        title: "default title",
        description: "default description"
      })
      |> Poffee.Social.create_brand_page(user)

    brand_page
  end

  @doc """
  Generate a comment.
  """
  def comment_fixture(user, feedback, attrs \\ %{}) do
    {:ok, comment} =
      attrs
      |> Enum.into(%{
        content: "default content"
      })
      |> Poffee.Social.create_comment(user.id, feedback.id)

    comment
  end
end
