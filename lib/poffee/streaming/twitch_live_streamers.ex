defmodule Poffee.Streaming.TwitchLiveStreamers do
  @moduledoc """
  This holds the state to represent a list of the current live streamers
  """

  use GenServer

  alias Poffee.Accounts
  alias Poffee.Social
  alias Poffee.Services.BrandPageService
  alias Poffee.Streaming
  alias Poffee.Streaming.Twitch.Streamer
  alias Poffee.Streaming.{TwitchApiConnector, TwitchSubscriptionManager}

  # PubSub topic
  @topic_live_streamers "topic:live_streamers"
  @topic_twitch "topic:twitch_"

  @dummy_email_domain "test.cc"
  @dummy_password "12341234"
  @dummy_content "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Senectus et netus et malesuada fames. Massa massa ultricies mi quis hendrerit. "

  # 20 secs timeout
  @timeout :timer.seconds(20)

  @default_number_streamers 30

  require Logger

  ################################################
  # Client APIs
  ################################################

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def subscribe_to_streaming_list() do
    Logger.debug("[TwitchLiveStreamers.subscribe_to_streaming_list] ")
    Phoenix.PubSub.subscribe(Poffee.PubSub, @topic_live_streamers)
  end

  def subscribe_to_streamer(twitch_user_id) do
    Logger.debug("[TwitchLiveStreamers.subscribe_to_streamer] #{twitch_user_id}")
    Phoenix.PubSub.subscribe(Poffee.PubSub, @topic_twitch <> twitch_user_id)
  end

  def current_streamers(pid \\ __MODULE__) do
    GenServer.call(pid, :current_streamers, @timeout)
  end

  # called by PoffeeWeb.TwitchWebhookController when we receive a webhook callback
  def user_online(pid \\ __MODULE__, twitch_user_id) do
    GenServer.cast(pid, {:online, twitch_user_id})
    {:ok, twitch_user_id}
  end

  # called by PoffeeWeb.TwitchWebhookController when we receive a webhook callback
  def user_offline(pid \\ __MODULE__, twitch_user_id) do
    GenServer.cast(pid, {:offline, twitch_user_id})
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
      case TwitchApiConnector.get_live_streamers(@default_number_streamers) do
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
    broadcast_online_streamer(new_streamer)

    {:noreply, streamers}
  end

  def handle_cast({:offline, twitch_user_id}, old_streamers) do
    updated_streamers =
      old_streamers
      |> Enum.reject(fn x -> x.twitch_user_id == twitch_user_id end)

    if updated_streamers != old_streamers do
      broadcast_updated_streamers(updated_streamers)
    end

    broadcast_offline_streamer(get_streamer_info(twitch_user_id))

    {:noreply, updated_streamers}
  end

  # TODO remove, for demo only
  # Retreive a fresh list of streamers, ignore any existing online streamers.
  @impl GenServer
  def handle_info(:get_live_streamers, old_streamers) do
    old_streamer_user_ids = old_streamers |> Enum.map(&Map.get(&1, :twitch_user_id))

    Logger.debug("[get_live_streamers] old_streamer_user_ids = #{inspect(old_streamer_user_ids)}")

    new_streamers =
      case TwitchApiConnector.get_live_streamers(@default_number_streamers) do
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
          Logger.debug("[get_live_streamers] New online streamers found.}")

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
          Streamer.new(
            user_info["id"],
            user_info["display_name"],
            user_info["login"],
            user_info["description"],
            user_info["profile_image_url"]
          )

        # TODO remove this - Save streamer to database for demo purposes
        Task.Supervisor.start_child(Poffee.Streaming.TaskSupervisor, fn ->
          maybe_create_user(streamer)
        end)

        streamer

      response ->
        Logger.error(
          "[TwitchLiveStreamers.get_streamer_info] returning nil for user_id #{twitch_user_id}, reason: #{inspect(response)}"
        )

        nil
    end
  end

  # TODO remove - for demo only
  # create a dummy user account for the streamer if not already exists in our db 
  defp maybe_create_user(%Streamer{} = streamer) do
    user_attrs = %{
      username: streamer.display_name,
      email: "twitch_#{streamer.twitch_user_id}_#{streamer.login}@#{@dummy_email_domain}",
      password: @dummy_password
    }

    twitch_user_attrs = %{
      twitch_user_id: streamer.twitch_user_id,
      description: streamer.description,
      display_name: streamer.display_name,
      login: streamer.login,
      profile_image_url: streamer.profile_image_url
    }

    # create user in db if not exists
    with nil <- Accounts.get_user_by_username(streamer.display_name),
         {:ok, user} <- Accounts.register_user(user_attrs),
         {:ok, _twitch_user} <- Streaming.create_twitch_user(twitch_user_attrs, user),
         {:ok, brand_page} <- create_demo_brandpage(user, streamer.description) do
      create_demo_feedbacks(user, brand_page)
    end
  end

  # TODO remove - for demo only
  defp create_demo_brandpage(user, description) do
    %{
      title: "#{user.username} - Twitch",
      description: description
    }
    |> BrandPageService.create_brand_page(user)
  end

  # TODO remove - for demo only
  defp create_demo_feedbacks(user, brand_page) do
    1..2
    |> Enum.each(fn n ->
      %{
        title: "Demo feedback #{n} for #{user.username}",
        content: @dummy_content
      }
      |> Social.create_feedback(user, brand_page)

      Process.sleep(2000)
    end)
  end

  defp maybe_subscribe_to_events(nil), do: nil

  defp maybe_subscribe_to_events(twitch_user_id) do
    TwitchSubscriptionManager.maybe_subscribe_stream_online(twitch_user_id)
    TwitchSubscriptionManager.maybe_subscribe_stream_offline(twitch_user_id)
    twitch_user_id
  end

  # only broadcast when new streamers are added to the list 
  defp broadcast_new_streamers(streamers) do
    Logger.debug("[broadcast_new_streamers]")

    Phoenix.PubSub.broadcast(
      Poffee.PubSub,
      @topic_live_streamers,
      {__MODULE__, :added_streamers, streamers}
    )
  end

  # only broadcast when streamers are removed from the list or other changes 
  defp broadcast_updated_streamers(streamers) do
    Logger.debug("[broadcast_updated_streamers]")

    Phoenix.PubSub.broadcast(
      Poffee.PubSub,
      @topic_live_streamers,
      {__MODULE__, :updated_streamers, streamers}
    )
  end

  defp broadcast_online_streamer(streamer) do
    Phoenix.PubSub.broadcast(
      Poffee.PubSub,
      @topic_twitch <> streamer.twitch_user_id,
      {__MODULE__, :online, streamer}
    )
  end

  defp broadcast_offline_streamer(streamer) do
    Phoenix.PubSub.broadcast(
      Poffee.PubSub,
      @topic_twitch <> streamer.twitch_user_id,
      {__MODULE__, :offline, streamer}
    )
  end
end
