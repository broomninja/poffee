defmodule Poffee.StreamingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Poffee.Streaming` context.
  """

  @doc """
  Generate a twitch_user.
  """
  def twitch_user_fixture(attrs \\ %{}) do
    {:ok, twitch_user} =
      attrs
      |> Enum.into(%{
        description: "some description",
        display_name: "some display_name",
        login: "some login",
        profile_image_url: "some profile_image_url",
        twitch_user_id: 42
      })
      |> Poffee.Streaming.create_twitch_user()

    twitch_user
  end
end