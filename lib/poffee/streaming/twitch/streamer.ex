defmodule Poffee.Streaming.Twitch.Streamer do
  @derive Jason.Encoder
  @enforce_keys [:twitch_user_id, :display_name, :login]
  defstruct @enforce_keys ++ [:profile_image_url, :description]

  def new(twitch_user_id, display_name, login, description, profile_image_url) do
    %__MODULE__{
      twitch_user_id: twitch_user_id,
      display_name: display_name,
      login: login,
      description: description,
      profile_image_url: profile_image_url
    }
  end
end
