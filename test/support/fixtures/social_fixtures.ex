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
        title: "default title"
      })
      |> Poffee.Social.create_feedback(user, brand_page)

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
end
