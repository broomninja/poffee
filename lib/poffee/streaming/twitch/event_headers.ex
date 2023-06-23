defmodule Poffee.Streaming.Twitch.EventHeaders do
  defstruct id: "",
            retry: false,
            type: :notification,
            signature: "",
            subscription_type: "",
            subscription_version: 0,
            timestamp: DateTime.utc_now()

  def new(headers) do
    %__MODULE__{
      id: headers["twitch-eventsub-message-id"],
      retry: headers["twitch-eventsub-message-retry"] == "true",
      type: parse_type(headers["twitch-eventsub-message-type"]),
      signature: headers["twitch-eventsub-message-signature"],
      timestamp: DateTime.from_iso8601(headers["twitch-eventsub-message-timestamp"]),
      subscription_type: headers["twitch-eventsub-subscription-type"],
      subscription_version: parse_integer(headers["twitch-eventsub-subscription-version"])
    }
  end

  defp parse_type("notification"), do: :notification
  defp parse_type("webhook_callback_verification"), do: :webhook_callback_verification
  defp parse_type("revocation"), do: :revocation
  defp parse_type(_), do: :unknown

  defp parse_integer(nil), do: 0
  defp parse_integer(str) when is_binary(str), do: Integer.parse(str)
end
