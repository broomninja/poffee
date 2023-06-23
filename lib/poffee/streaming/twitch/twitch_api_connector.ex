defmodule Poffee.Streaming.TwitchApiConnector do
  use GenServer

  alias Poffee.{Env, PubSub}

  require Logger

  ################################################
  # Client APIs
  ################################################

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def subscribe_stream_online(twitch_user_id) do
    GenServer.cast(__MODULE__, {:stream_online, twitch_user_id})
    {:ok, twitch_user_id}
  end

  def subscribe_stream_offline(twitch_user_id) do
    GenServer.cast(__MODULE__, {:stream_offline, twitch_user_id})
    {:ok, twitch_user_id}
  end

  ################################################
  # Server callbacks
  ################################################

  @impl true
  def init(state) do
    Process.flag(:trap_exit, true)

    client_id = Env.twitch_client_id()
    client_secret = Env.twitch_client_secret()

    # Get a fresh token on startup
    # TODO expires in 60 days, add token refresh logic
    {:ok, %{"access_token" => app_access_token}} =
      TwitchApi.Auth.get_app_access_token!(client_id, client_secret)

    state =
      state
      |> Map.put(:client_id, client_id)
      |> Map.put(:client_secret, client_secret)
      |> Map.put(:callback_webhook_uri, Env.twitch_callback_webhook_uri())
      |> Map.put(:secret, Env.endpoint_secret())
      |> Map.put(:app_access_token, app_access_token)

    # remove any previous subscriptions
    remove_subscriptions(state)

    {:ok, state}
  end

  @impl true
  def handle_cast({:stream_online, twitch_user_id}, state) do
    case TwitchApi.EventSub.listen_to_stream_online(
           Map.get(state, :client_id),
           Map.get(state, :app_access_token),
           Map.get(state, :callback_webhook_uri),
           Map.get(state, :secret),
           twitch_user_id
         ) do
      {:ok, response} ->
        Logger.debug("stream_online subscription done: #{inspect(response)}")

      {:error, error_message} ->
        Logger.error("stream_online subscription error: #{error_message}")
    end

    {:noreply, state}
  end

  def handle_cast({:stream_offline, twitch_user_id}, state) do
    case TwitchApi.EventSub.listen_to_stream_offline(
           Map.get(state, :client_id),
           Map.get(state, :app_access_token),
           Map.get(state, :callback_webhook_uri),
           Map.get(state, :secret),
           twitch_user_id
         ) do
      {:ok, response} ->
        Logger.debug("stream_offline subscription done: #{inspect(response)}")

      {:error, error_message} ->
        Logger.error("stream_offline subscription error: #{error_message}")
    end

    {:noreply, state}
  end

  @impl true
  def handle_info({:EXIT, _from, :normal}, state) do
    terminate(:normal, state)
  end

  @impl true
  def terminate(_reason, state) do
    remove_subscriptions(state)
    Logger.info("[TwitchApiConnector] terminated")
  end

  ################################################
  # Private/utility methods
  ################################################

  defp remove_subscriptions(state) do
    client_id = Map.get(state, :client_id)
    app_access_token = Map.get(state, :app_access_token)

    # get the current list of subscriptions and remove them
    case TwitchApi.EventSub.list_event_subs(client_id, app_access_token) do
      {:ok, %{"data" => data}} ->
        data
        |> Enum.each(fn %{"id" => id} ->
          Logger.info("[TwitchApiConnector] Removing twitch subscription id #{id}")
          TwitchApi.EventSub.stop_listening(client_id, app_access_token, id)
        end)

      {:ok, %{"error" => _error} = message} ->
        Logger.error("[TwitchApiConnector.list_event_subs] #{message}")
        
      {:error, message} ->
        Logger.error("[TwitchApiConnector.list_event_subs] #{message}")
    end
  end
end
