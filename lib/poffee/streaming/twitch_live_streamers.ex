defmodule Poffee.Streaming.TwitchLiveStreamers do
  @moduledoc """
  This holds the state to represent a list of the current live streamers
  """

  use GenServer

  alias Poffee.Accounts
  alias Poffee.Services.BrandPageService
  alias Poffee.Streaming.Twitch.Streamer
  alias Poffee.Streaming.{TwitchApiConnector, TwitchSubscriptionManager}

  # PubSub topic
  @topic "topic_live_streamers"

  # 20 secs timeout
  @timeout :timer.seconds(20)

  require Logger

  ################################################
  # Client APIs
  ################################################

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def subscribe() do
    Phoenix.PubSub.subscribe(Poffee.PubSub, @topic)
  end

  def current_streamers() do
    GenServer.call(__MODULE__, :current_streamers, @timeout)
  end

  # called by PoffeeWeb.TwitchWebhookController when we receive a webhook callback
  def user_online(twitch_user_id) do
    GenServer.cast(__MODULE__, {:online, twitch_user_id})
    {:ok, twitch_user_id}
  end

  # called by PoffeeWeb.TwitchWebhookController when we receive a webhook callback
  def user_offline(twitch_user_id) do
    GenServer.cast(__MODULE__, {:offline, twitch_user_id})
    {:ok, twitch_user_id}
  end

  ################################################
  # Server callbacks
  ################################################

  @impl GenServer
  def init(arg) do
    {:ok, arg, {:continue, :load}}
  end

  @impl GenServer
  def handle_continue(:load, _arg) do
    streamers =
      case TwitchApiConnector.get_live_streamers() do
        {:ok, %{"data" => results}} ->
          results
          |> Stream.map(&Map.get(&1, "user_id"))
          |> Stream.map(&maybe_subscribe_to_events(&1))
          |> Stream.map(&get_streamer_info(&1))
          |> Enum.to_list()

        _ ->
          nil
      end

    # TODO remove, for demo purposes
    Process.send_after(self(), :get_live_streamers, 30_000)
    {:noreply, streamers}
  end

  @impl GenServer
  def handle_call(:current_streamers, _from, streamers) do
    {:reply, streamers, streamers}
  end

  @impl GenServer
  def handle_cast({:online, twitch_user_id}, streamers) do
    new_streamer = get_streamer_info(twitch_user_id)

    streamers = [new_streamer | streamers]

    broadcast_new_streamers(streamers)

    {:noreply, streamers}
  end

  def handle_cast({:offline, twitch_user_id}, old_streamers) do
    updated_streamers =
      old_streamers
      |> Enum.reject(fn x -> x.user_id == twitch_user_id end)

    if updated_streamers != old_streamers do
      broadcast_updated_streamers(updated_streamers)
    end

    {:noreply, updated_streamers}
  end

  # TODO remove, for demo only
  # Retreive a fresh list of streamers, ignore any existing online streamers.
  @impl GenServer
  def handle_info(:get_live_streamers, old_streamers) do
    old_streamer_user_ids = old_streamers |> Enum.map(&Map.get(&1, :user_id))

    Logger.debug("[get_live_streamers] old_streamer_user_ids = #{inspect(old_streamer_user_ids)}")

    new_streamers =
      case TwitchApiConnector.get_live_streamers() do
        {:ok, %{"data" => results}} ->
          results
          |> Stream.map(&Map.get(&1, "user_id"))
          |> Stream.reject(&(&1 in old_streamer_user_ids))
          |> Stream.map(&maybe_subscribe_to_events(&1))
          |> Stream.map(&get_streamer_info(&1))
          |> Enum.to_list()

        error ->
          Logger.error("[get_live_streamers] error: #{inspect(error)}")
          []
      end

    streamers =
      case new_streamers do
        [head | _tail] ->
          Logger.debug(
            "[get_live_streamers] New online streamers found: #{inspect(new_streamers)}"
          )

          # we are only interested in the first new streamer, for demo only 
          list = [head | old_streamers]
          broadcast_new_streamers(list)
          list

        _ ->
          Logger.debug("[get_live_streamers] No new online streamers found")
          old_streamers
      end

    Process.send_after(self(), :get_live_streamers, 30_000)
    {:noreply, streamers}
  end

  ################################################
  # Private/utility methods
  ################################################

  defp get_streamer_info(nil), do: nil

  defp get_streamer_info(twitch_user_id) do
    case TwitchApiConnector.get_user_info(twitch_user_id) do
      {:ok, %{"data" => [user_info]}} ->
        # return Streamer struct
        streamer =
          Streamer.new(user_info["id"], user_info["display_name"], user_info["profile_image_url"])

        # Save streamer to database
        maybe_create_user(streamer)

      response ->
        Logger.error(
          "[TwitchLiveStreamers.get_streamer_info] returning nil for user_id #{twitch_user_id}, reason: #{inspect(response)}"
        )

        nil
    end
  end

  # TODO remove - for demo only
  # create a dummy user account for the streamer if not in our database already 
  defp maybe_create_user(%Streamer{} = streamer) do
    user_attrs = %{
      username: streamer.display_name,
      email: "twitch_" <> streamer.user_id <> "@test.cc",
      password: "12341234"
    }

    with nil <- Accounts.get_user_by_username(streamer.display_name),
         {:ok, user} <- Accounts.register_user(user_attrs) do
      brand_page_attrs = %{
        title: "Fan Page for Twitch streamer " <> streamer.display_name,
        description: ""
      }

      BrandPageService.create_brand_page(brand_page_attrs, user)
    end

    streamer
  end

  defp maybe_subscribe_to_events(nil), do: nil

  defp maybe_subscribe_to_events(twitch_user_id) do
    TwitchSubscriptionManager.maybe_subscribe_stream_offline(twitch_user_id)
    twitch_user_id
  end

  # only broadcast when new streamers are added to the list 
  defp broadcast_new_streamers(streamers) do
    Logger.debug("[broadcast_new_streamers]")
    Phoenix.PubSub.broadcast(Poffee.PubSub, @topic, {:added_streamers, streamers})
  end

  # only broadcast when streamers are removed from the list or other changes 
  defp broadcast_updated_streamers(streamers) do
    Logger.debug("[broadcast_updated_streamers]")
    Phoenix.PubSub.broadcast(Poffee.PubSub, @topic, {:updated_streamers, streamers})
  end
end
