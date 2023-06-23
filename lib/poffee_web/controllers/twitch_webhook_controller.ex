defmodule PoffeeWeb.TwitchWebhookController do
  use PoffeeWeb, :controller

  alias Poffee.Env
  alias Poffee.Streaming.Twitch.{Event}

  require Logger

  @spec handle_event(Plug.Conn.t(), map) :: Plug.Conn.t()
  def handle_event(%Plug.Conn{} = conn, _opts) do
    twitch_headers = parse_twitch_headers(conn)
    raw_body = raw_body(conn)

    if signature_valid?(twitch_headers, raw_body) do
      Logger.debug("[TwitchWebhookController.handle_event] signature is valid")
      event = Event.new(Enum.into(conn.req_headers, %{}), conn.params)

      case process_event(event.headers.type, event) do
        {:ok, data} ->
          conn |> put_resp_content_type("text/plain") |> send_resp(200, data) |> halt

        _ ->
          Logger.debug("[TwitchWebhookController.handle_event] process_event failed")
          conn |> send_resp(:unauthorized, "") |> halt
      end
    else
      Logger.info("[TwitchWebhookController.handle_event] Invalid signature headers")
      conn |> send_resp(:unauthorized, "") |> halt
    end
  end

  @spec parse_twitch_headers(Plug.Conn.t()) :: map
  defp parse_twitch_headers(conn) do
    message_id = get_req_header(conn, "twitch-eventsub-message-id") |> List.first()
    timestamp = get_req_header(conn, "twitch-eventsub-message-timestamp") |> List.first()
    signature = get_req_header(conn, "twitch-eventsub-message-signature") |> List.first()

    %{}
    |> maybe_put(:message_id, message_id)
    |> maybe_put(:timestamp, timestamp)
    |> maybe_put(:signature, signature)
  end

  defp maybe_put(headers, _key, nil), do: headers
  defp maybe_put(headers, key, value), do: Map.put(headers, key, value)

  defp raw_body(conn) do
    case conn do
      %Plug.Conn{assigns: %{raw_body: raw_body}} ->
        # We cached as iodata, so we need to transform here.
        IO.iodata_to_binary(raw_body)

      _ ->
        # If we forget to use the plug or there is no content-type on the request
        # raise "raw body is not present or request content-type is missing"
        nil
    end
  end

  defp signature_valid?(_headers, nil), do: false

  defp signature_valid?(
         %{message_id: message_id, timestamp: timestamp, signature: signature},
         raw_data
       ) do
    signature_input = "#{message_id}#{timestamp}#{raw_data}"

    # Logger.debug("[signature_valid] raw_data #{raw_data}")
    # Logger.debug("[signature_valid] signature_input #{signature_input}")
    # Logger.debug("[signature_valid] Env.endpoint_secret #{Env.endpoint_secret()}")

    hmac =
      "sha256=" <>
        (:crypto.mac(:hmac, :sha256, Env.endpoint_secret(), signature_input)
         |> Base.encode16(case: :lower))

    Plug.Crypto.secure_compare(hmac, signature)
  end

  defp signature_valid?(_headers, _raw_data), do: false

  defp process_event(:webhook_callback_verification, %Event{} = event) do
    challenge = event.body["challenge"]

    Logger.info(
      "[TwitchWebhookController.process_event] webhook_callback_verification challenge = #{challenge}"
    )

    {:ok, challenge}
  end

  defp process_event(:notification, %Event{} = event) do
    case {
      event.headers.subscription_type,
      event.body["subscription"]["condition"]
    } do
      {type, %{"broadcaster_user_id" => user_id}} ->
        Logger.info(
          "[TwitchWebhookController.process_event] received subscription type #{type} for user_id #{user_id}"
        )

      # pubsub_event = %PubSub.Event.EventsubNotification{
      #   type: type,
      #   event: event.body["event"],
      #   id: event.headers.id
      # }

      # PubSub.broadcast_user_event!(
      #   user_id,
      #   pubsub_event
      # )

      {type, _} ->
        Logger.error(
          "[webhook controller] unknown subscription type #{type} #{inspect(event.body["subscription"]["condition"])}"
        )
    end

    {:ok, ""}
  end

  defp process_event(:revocation, _event), do: {:ok, "Authorization revoked"}
  defp process_event(:unknown, _event), do: {:ok, "Unknown event type"}
end
