defmodule Poffee.StreamingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Poffee.Streaming` context.
  """

  @doc """
  Generate a twitch_user.
  """
  def twitch_user_fixture(user, attrs \\ %{}) do
    {:ok, twitch_user} =
      attrs
      |> Enum.into(%{
        description: "some description",
        display_name: user.username,
        login: "some login",
        profile_image_url: "https://some.website.com/profile_image_url",
        twitch_user_id: "42"
      })
      |> Poffee.Streaming.create_twitch_user(user)

    twitch_user
  end
end
