defmodule Poffee.SocialFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Poffee.Social` context.
  """

  @doc """
  Generate a feedback.
  """
  def feedback_fixture(attrs \\ %{}) do
    {:ok, feedback} =
      attrs
      |> Enum.into(%{
        content: "some content",
        title: "some title"
      })
      |> Poffee.Social.create_feedback()

    feedback
  end

  @doc """
  Generate a brand_page.
  """
  def brand_page_fixture(attrs \\ %{}) do
    {:ok, brand_page} =
      attrs
      |> Enum.into(%{
        title: "some title"
      })
      |> Poffee.Social.create_brand_page()

    brand_page
  end
end
