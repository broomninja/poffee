defmodule Poffee.Streaming.TwitchApiMock.EventSub do
  def listen_to_stream_online(_client_id, _app_access_token, _callback_url, _secret, _channel) do
    {:ok, nil}
  end

  def listen_to_stream_offline(_client_id, _app_access_token, _callback_url, _secret, _channel) do
    {:ok, nil}
  end

  def stop_listening(_client_id, _app_access_token, _subscription_id) do
    {:ok, nil}
  end

  def list_event_subs(_client_id, _app_access_token, _cursor \\ nil) do
    {:error, "Mock error message, please ignore."}
  end
end
