defmodule PoffeeWeb.UserLive do
  use PoffeeWeb, :live_view

  alias Poffee.Accounts.User
  alias Poffee.Social
  alias Poffee.Social.BrandPage
  alias Poffee.Streaming.{TwitchApiConnector, TwitchLiveStreamers}

  require Logger

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    socket =
      socket
      #   |> PhoenixLiveSession.maybe_subscribe(session)
      |> assign_new(:current_user, fn -> nil end)
      |> assign_new(:streaming_status, fn -> "blank" end)

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_params(%{"username" => username}, _url, socket) do
    socket =
      case Social.get_user_with_brand_page_and_feedbacks_by_username(username) do
        nil ->
          socket
          |> assign(:user_found, nil)
          |> assign_page_title(nil, username)

        %User{} = user ->
          Logger.debug("[handle_params(username)] connected? #{connected?(socket)}")
          # fetch online status from API in the background, see handle_info below
          if connected?(socket), do: send(self(), {:get_streaming_status, user})

          socket
          |> assign(:user_found, user)
          |> assign(:streaming_status, "loading")
          |> assign_page_title(user.brand_page, username)
          |> maybe_subscribe_to_events(user)
      end

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  # PubSub messages from TwitchLiveStreamers
  def handle_info({:online, streamer}, socket) do
    Logger.debug("[UserLive.online] #{streamer.display_name}")
    # check if streamer is displayed
    user = socket.assigns.user_found

    socket =
      if user.username == streamer.display_name do
        assign(socket, :streaming_status, "online")
      else
        Logger.warning(
          "[UserLive.online] Streaming status for #{streamer.display_name} does not belong to current user: #{user.username}"
        )

        socket
      end

    {:noreply, socket}
  end

  # PubSub messages from TwitchLiveStreamers
  def handle_info({:offline, streamer}, socket) do
    Logger.debug("[UserLive.offline] #{streamer.display_name}")

    # check if streamer is displayed
    user = socket.assigns.user_found

    socket =
      if user.username == streamer.display_name do
        assign(socket, :streaming_status, "offline")
      else
        Logger.warning(
          "[UserLive.offline] Streaming status for #{streamer.display_name} does not belong to current user: #{user.username}"
        )

        socket
      end

    {:noreply, socket}
  end

  # message sent by self only
  def handle_info({:get_streaming_status, user}, socket) do
    Logger.debug("[UserLive.get_streaming_status] #{user.username}")

    socket =
      with %{"user_id" => twitch_user_id} <- get_twitch_user_id(user) do
        case TwitchApiConnector.is_user_online?(twitch_user_id) do
          true -> assign(socket, :streaming_status, "online")
          false -> assign(socket, :streaming_status, "offline")
        end
      else
        # not a twitch broadcaster
        nil -> assign(socket, :streaming_status, "blank")
      end

    {:noreply, socket}
  end

  defp assign_page_title(socket, nil, username) do
    assign(socket, :page_title, username)
  end

  defp assign_page_title(socket, %BrandPage{} = brand_page, _username) do
    assign(socket, :page_title, brand_page.title)
  end

  defp maybe_subscribe_to_events(socket, nil), do: socket

  defp maybe_subscribe_to_events(socket, user) do
    if connected?(socket) do
      with %{"user_id" => twitch_user_id} <- get_twitch_user_id(user) do
        TwitchLiveStreamers.subscribe_to_streamer(twitch_user_id)
      end
    end

    socket
  end

  # TODO: this is for demo only. 
  #
  # If the user is created by us automatically from the twitch API, we will return a map
  # in the format of: 
  #
  #   %{"user_id" => twitch_user_id}
  #
  # If the user is not a twitch broadcaster, returns nil
  defp get_twitch_user_id(user) do
    Regex.named_captures(~r/^twitch_(?<user_id>\d+)@test.cc$/, user.email)
  end
end
