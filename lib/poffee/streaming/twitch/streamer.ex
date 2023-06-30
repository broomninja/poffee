defmodule Poffee.Streaming.Twitch.Streamer do
  @derive Jason.Encoder
  @enforce_keys [:user_id, :display_name]
  defstruct @enforce_keys ++ [:profile_url]

  def new(user_id, display_name, profile_url) do
    %__MODULE__{
      user_id: user_id,
      display_name: display_name,
      profile_url: profile_url
    }
  end
end
