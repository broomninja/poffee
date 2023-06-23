defmodule Poffee.Env do
  # Twitch env vars
  def twitch_client_id, do: get_env(:twitch)[:client_id]
  def twitch_client_secret, do: get_env(:twitch)[:client_secret]
  def twitch_callback_webhook_uri, do: get_env(:twitch)[:callback_webhook_uri]

  def endpoint_secret, do: get_env(PoffeeWeb.Endpoint)[:secret_key_base]

  defp get_env(name), do: Application.get_env(:poffee, name)
end
