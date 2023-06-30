defmodule Poffee.Streaming.Twitch.Subscription do
  defstruct id: "",
            user_id: "",
            subscription_type: ""

  def new(map) do
    %__MODULE__{
      id: map["id"],
      user_id: map["condition"]["broadcaster_user_id"],
      subscription_type: map["type"]
    }
  end
end
