defmodule PoffeeWeb.TwitchWebhookController do
  use PoffeeWeb, :controller

  alias Poffee.Env
  alias Poffee.Streaming.TwitchLiveStreamers
  alias Poffee.Streaming.Twitch.Event

  require Logger

  # check if signature is within 10 mins
  @valid_period_in_seconds 600

  @spec handle_event(Plug.Conn.t(), map) :: Plug.Conn.t()
  def handle_event(%Plug.Conn{} = conn, _opts) do
    twitch_headers = parse_twitch_headers(conn)
    raw_body = raw_body(conn)

    case verify_signature(twitch_headers, raw_body) do
      {:ok, valid_message} ->
        Logger.debug("[TwitchWebhookController.handle_event] #{valid_message}")
        event = Event.new(Enum.into(conn.req_headers, %{}), conn.params)

        case process_event(event.headers.type, event) do
          {:ok, data} ->
            conn |> put_resp_content_type("text/plain") |> send_resp(200, data) |> halt

          _ ->
            Logger.warning("[TwitchWebhookController.handle_event] process_event failed")
            conn |> send_resp(:unauthorized, "") |> halt
        end

      {:error, error_message} ->
        Logger.info(
          "[TwitchWebhookController.handle_event] Invalid signature headers: #{error_message}"
        )

        conn |> send_resp(:unauthorized, error_message) |> halt
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

  defp verify_signature(_headers, nil), do: {:error, "missing raw body"}

  defp verify_signature(
         %{message_id: message_id, timestamp: timestamp, signature: signature},
         raw_data
       ) do
    signature_input = "#{message_id}#{timestamp}#{raw_data}"

    Logger.debug("[verify_signature] message_id #{message_id}")
    Logger.debug("[verify_signature] timestamp #{timestamp}")
    # Logger.debug("[verify_signature] signature_input #{signature_input}")
    # Logger.debug("[verify_signature] Env.endpoint_secret #{Env.endpoint_secret()}")

    current_timestamp = System.system_time(:second)
    # header timestamp is in the format of "2023-06-23T02:06:42.358555867Z"
    # need to convert it to unix epoch for comparison eg 1687486002
    {:ok, signature_datetime, _offset} = DateTime.from_iso8601(timestamp)
    signature_timestamp_in_seconds = DateTime.to_unix(signature_datetime)

    hmac =
      "sha256=" <>
        (:crypto.mac(:hmac, :sha256, Env.endpoint_secret(), signature_input)
         |> Base.encode16(case: :lower))

    cond do
      signature_timestamp_in_seconds + @valid_period_in_seconds < current_timestamp ->
        {:error, "signature is too old"}

      not Plug.Crypto.secure_compare(hmac, signature) ->
        {:error, "signature is incorrect"}

      true ->
        {:ok, "valid signature"}
    end
  end

  defp verify_signature(_headers, _raw_data), do: {:error, "missing header(s)"}

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
      {"stream.online" = type, %{"broadcaster_user_id" => user_id}} ->
        Logger.info(
          "[TwitchWebhookController.process_event] received subscription type #{type} for user_id #{user_id}"
        )

        TwitchLiveStreamers.user_online(user_id)

      {"stream.offline" = type, %{"broadcaster_user_id" => user_id}} ->
        Logger.info(
          "[TwitchWebhookController.process_event] received subscription type #{type} for user_id #{user_id}"
        )

        TwitchLiveStreamers.user_offline(user_id)

      {type, _} ->
        Logger.warning(
          "[webhook controller] unknown subscription type #{type} #{inspect(event.body["subscription"]["condition"])}"
        )
    end

    {:ok, ""}
  end

  defp process_event(:revocation, _event), do: {:ok, "Authorization revoked"}
  defp process_event(:unknown, _event), do: {:ok, "Unknown event type"}
end
