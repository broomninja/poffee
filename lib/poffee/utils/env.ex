defmodule Poffee.Env do
  # LiveSvelte SSR
  def livesvelte_enable_ssr, do: get_env(:live_svelte)[:enable_ssr]

  # API mock
  def twitch_api_client, do: get_env(:twitch)[:api_client]

  # Twitch env vars
  def twitch_client_id, do: get_env(:twitch)[:client_id]
  def twitch_client_secret, do: get_env(:twitch)[:client_secret]
  def twitch_callback_webhook_uri, do: get_env(:twitch)[:callback_webhook_uri]

  # PoffeeWeb.Endpoint
  def endpoint_secret, do: get_env(PoffeeWeb.Endpoint)[:secret_key_base]

  # Compile Env
  def compile_env, do: get_env(:compile_env)

  defp get_env(name), do: Application.get_env(:poffee, name)
end
