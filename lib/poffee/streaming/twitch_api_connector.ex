defmodule Poffee.Streaming.TwitchApiConnector do
  @moduledoc """
  GenServer process that connects to the Twitch APi.

  We only need a single instance of TwitchApiConnector
  """

  use GenServer

  alias Poffee.Env

  require Logger

  defmodule State do
    @type t :: %State{
            twitch_api_client: module(),
            client_id: String.t(),
            client_secret: String.t(),
            callback_webhook_uri: String.t(),
            endpoint_secret: String.t(),
            app_access_token: String.t()
          }

    defstruct ~w(
      twitch_api_client
      client_id
      client_secret
      callback_webhook_uri
      endpoint_secret
      app_access_token
      )a
  end

  # 20 secs timeout
  @timeout :timer.seconds(20)

  ################################################
  # Client APIs
  ################################################

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def is_user_online?(pid \\ __MODULE__, twitch_user_id) do
    GenServer.call(pid, {:is_user_online, twitch_user_id}, @timeout)
  end

  def get_user_info(pid \\ __MODULE__, twitch_user_id) do
    GenServer.call(pid, {:get_user_info, twitch_user_id}, @timeout)
  end

  def get_live_streamers(pid \\ __MODULE__, number) do
    GenServer.call(pid, {:get_live_streamers, number}, @timeout)
  end

  def get_event_subscriptions(pid \\ __MODULE__) do
    GenServer.call(pid, :get_event_subscriptions, @timeout)
  end

  def remove_subscription(pid \\ __MODULE__, subscription_id) do
    GenServer.call(pid, {:remove_subscription, subscription_id}, @timeout)
  end

  @doc """
  Get nofication when a given user is online
  """
  def subscribe_stream_online(pid \\ __MODULE__, twitch_user_id) do
    GenServer.cast(pid, {:stream_online, twitch_user_id})
    {:ok, twitch_user_id}
  end

  def subscribe_stream_offline(pid \\ __MODULE__, twitch_user_id) do
    GenServer.cast(pid, {:stream_offline, twitch_user_id})
    {:ok, twitch_user_id}
  end

  ################################################
  # Server callbacks
  ################################################

  @impl GenServer
  def init(opts) do
    Process.flag(:trap_exit, true)

    twitch_api_client = Keyword.fetch!(opts, :twitch_api_client)

    state =
      %State{twitch_api_client: twitch_api_client}
      |> get_webhook_env
      |> refresh_access_token

    {:ok, state, {:continue, :refresh_subscriptions}}
  end

  @impl GenServer
  def handle_continue(:refresh_subscriptions, state) do
    # Task.Supervisor.start_child(Poffee.Streaming.TaskSupervisor, fn ->
    #   remove_subscriptions(state)
    # end)

    {:noreply, state}
  end

  @impl GenServer
  def handle_call({:is_user_online, twitch_user_id}, _from, state) do
    is_live =
      twitch_api_client(state, Helix).is_live?(
        state.client_id,
        state.app_access_token,
        twitch_user_id
      )

    {:reply, is_live, state}
  end

  def handle_call({:get_user_info, twitch_user_id}, _from, state) do
    user_info =
      twitch_api_client(state, Helix).get_user_info_by_user_id!(
        state.client_id,
        state.app_access_token,
        twitch_user_id
      )

    {:reply, user_info, state}
  end

  def handle_call({:get_live_streamers, number}, _from, state) do
    streamers =
      twitch_api_client(state, Helix).list_streamers(
        state.client_id,
        state.app_access_token,
        number
      )

    {:reply, streamers, state}
  end

  def handle_call(:get_event_subscriptions, _from, state) do
    subscriptions =
      case twitch_api_client(state, EventSub).list_event_subs(
             state.client_id,
             state.app_access_token
           ) do
        {:ok, %{"data" => data}} ->
          data

        {:ok, %{"error" => _error} = message} ->
          if Env.compile_env() != :test do
            Logger.error("[TwitchApiConnector.get_event_subscriptions] #{inspect(message)}")
          end

          nil

        {:error, message} ->
          if Env.compile_env() != :test do
            Logger.error("[TwitchApiConnector.get_event_subscriptions] #{inspect(message)}")
          end

          nil
      end

    {:reply, subscriptions, state}
  end

  def handle_call({:remove_subscription, subscription_id}, _from, state) do
    result =
      twitch_api_client(state, EventSub).stop_listening(
        state.client_id,
        state.app_access_token,
        subscription_id
      )

    {:reply, result, state}
  end

  @impl GenServer
  def handle_cast({:stream_online, twitch_user_id}, state) do
    case twitch_api_client(state, EventSub).listen_to_stream_online(
           state.client_id,
           state.app_access_token,
           state.callback_webhook_uri,
           state.endpoint_secret,
           twitch_user_id
         ) do
      {:ok, response} ->
        Logger.debug("[TwitchApiConnector.stream_online] subscription done: #{inspect(response)}")

      {:error, error_message} ->
        Logger.warning(
          "[TwitchApiConnector.stream_online] subscription for #{twitch_user_id} error: #{error_message}"
        )
    end

    {:noreply, state}
  end

  def handle_cast({:stream_offline, twitch_user_id}, state) do
    case twitch_api_client(state, EventSub).listen_to_stream_offline(
           state.client_id,
           state.app_access_token,
           state.callback_webhook_uri,
           state.endpoint_secret,
           twitch_user_id
         ) do
      {:ok, response} ->
        Logger.debug(
          "[TwitchApiConnector.stream_offline] subscription done: #{inspect(response)}"
        )

      {:error, error_message} ->
        Logger.warning(
          "[TwitchApiConnector.stream_offline] subscription for #{twitch_user_id} error: #{error_message}"
        )
    end

    {:noreply, state}
  end

  @impl GenServer
  def handle_info({:EXIT, _from, :normal}, state) do
    terminate(:normal, state)
  end

  @impl GenServer
  def terminate(_reason, state) do
    Logger.info("[TwitchApiConnector] terminated")
    {:noreply, state}
  end

  ################################################
  # Private/utility methods
  ################################################

  defp twitch_api_client(state, module_alias) do
    Module.concat(state.twitch_api_client, module_alias)
  end

  defp get_webhook_env(state) do
    state
    |> Map.put(:client_id, Env.twitch_client_id())
    |> Map.put(:client_secret, Env.twitch_client_secret())
    |> Map.put(:callback_webhook_uri, Env.twitch_callback_webhook_uri())
    |> Map.put(:endpoint_secret, Env.endpoint_secret())
  end

  # Get a fresh token on startup. Access token expires in 60 days.
  # TODO Add token refresh logic.
  #      Move this to a worker process that we can refresh periodically
  #      Consider using the Parent library: https://hex.pm/packages/parent
  defp refresh_access_token(state) do
    {:ok, %{"access_token" => app_access_token}} =
      twitch_api_client(state, Auth).get_app_access_token!(state.client_id, state.client_secret)

    state
    |> Map.put(:app_access_token, app_access_token)
  end
end
