defmodule Poffee.Streaming.Twitch.Event do
  alias Poffee.Streaming.Twitch.EventHeaders

  defstruct headers: %EventHeaders{}, body: %{}

  def new(headers, body) do
    %__MODULE__{
      headers: EventHeaders.new(headers),
      body: body
    }
  end
end
