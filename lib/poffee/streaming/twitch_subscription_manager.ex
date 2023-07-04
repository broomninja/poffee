defmodule Poffee.Streaming.TwitchSubscriptionManager do
  @moduledoc """
  Keeps track of subscriptions made to the Twitch API.

  We will check if the subscription is already in place before making a
  network call via the API.
  """

  use GenServer

  alias Poffee.Env
  alias Poffee.Streaming.TwitchApiConnector
  alias Poffee.Streaming.Twitch.Subscription

  require Logger

  # 20 secs timeout
  @timeout :timer.seconds(20)

  ################################################
  # Client APIs
  ################################################

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def clear_subscriptions() do
    GenServer.call(__MODULE__, :clear_subscriptions, @timeout)
  end

  def maybe_subscribe_stream_online(twitch_user_id) do
    GenServer.cast(__MODULE__, {:maybe_subscribe_stream_online, twitch_user_id})
    {:ok, twitch_user_id}
  end

  def maybe_subscribe_stream_offline(twitch_user_id) do
    GenServer.cast(__MODULE__, {:maybe_subscribe_stream_offline, twitch_user_id})
    {:ok, twitch_user_id}
  end

  ################################################
  # Server callbacks
  ################################################

  @impl GenServer
  def init(arg) do
    {:ok, get_subscriptions(arg)}
  end

  @impl GenServer
  def handle_call(:clear_subscriptions, _from, subscriptions) do
    subscriptions =
      subscriptions
      |> Enum.filter(fn sub ->
        case TwitchApiConnector.remove_subscription(sub.id) do
          {:ok, _} ->
            Logger.info(
              "[TwitchSubscriptionManager.clear_subscriptions] subscription #{sub.id} removed"
            )

            true
        end
      end)

    {:reply, :ok, subscriptions}
  end

  @impl GenServer
  def handle_cast({:maybe_subscribe_stream_online, twitch_user_id}, subscriptions) do
    if subscription_active?(subscriptions, "stream.online", twitch_user_id) do
      Logger.debug(
        "[TwitchSubscriptionManager.maybe_subscribe_stream_online] active subscription already exists for user_id #{twitch_user_id}"
      )
    else
      TwitchApiConnector.subscribe_stream_online(twitch_user_id)
      Process.send_after(self(), :update_subscriptions, 10_000)
    end

    {:noreply, subscriptions}
  end

  def handle_cast({:maybe_subscribe_stream_offline, twitch_user_id}, subscriptions) do
    if subscription_active?(subscriptions, "stream.offline", twitch_user_id) do
      Logger.debug(
        "[TwitchSubscriptionManager.maybe_subscribe_stream_offline] active subscription already exists for user_id #{twitch_user_id}"
      )
    else
      TwitchApiConnector.subscribe_stream_offline(twitch_user_id)
      Process.send_after(self(), :update_subscriptions, 10_000)
    end

    {:noreply, subscriptions}
  end

  @impl GenServer
  def handle_info(:update_subscriptions, _subscriptions) do
    {:noreply, get_subscriptions(nil)}
  end

  ################################################
  # Private/utility methods
  ################################################

  defp subscription_active?(subscriptions, event_type, twitch_user_id) do
    Enum.any?(subscriptions, fn x ->
      x.subscription_type == event_type && x.user_id == twitch_user_id
    end)
  end

  # get the current list of subscriptions from the API and store them locally
  defp get_subscriptions(_) do
    subs = TwitchApiConnector.get_event_subscriptions()

    subscriptions =
      case subs do
        # list with at least one element
        [_head | _tail] ->
          subs
          |> Stream.filter(&(Map.get(&1, "status") == "enabled"))
          |> Stream.map(&Subscription.new(&1))
          |> Enum.to_list()

        # empty list
        [] ->
          Logger.info("[TwitchSubscriptionManager.get_subscriptions] No subscriptions found.")
          []

        # nil or other non-list type
        other ->
          if Env.compile_env() != :test do
            Logger.error("[TwitchSubscriptionManager.get_subscriptions] #{inspect(other)}")
          end

          []
      end

    subscriptions
  end
end
