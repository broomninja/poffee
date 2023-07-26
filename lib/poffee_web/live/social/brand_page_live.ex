defmodule PoffeeWeb.BrandPageLive do
  use PoffeeWeb, :live_view

  alias Poffee.Accounts.User
  alias Poffee.Notifications
  alias Poffee.Social
  alias Poffee.Social.BrandPage
  alias Poffee.Social.BrandPageComponent
  alias Poffee.Streaming.{TwitchUser, TwitchApiConnector, TwitchLiveStreamers}
  alias Poffee.Streaming.Twitch.Streamer

  require Logger

  @default_assigns %{
    feedback_id: nil,
    twitch_user: nil,
    streaming_status: "blank"
  }

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, assign(socket, @default_assigns), temporary_assigns: []}
  end

  @impl Phoenix.LiveView

  # Loads a specific feedback and its comments from db using the feedback_id
  # @live_action == :show_single_feedback
  def handle_params(%{"username" => username, "feedback_id" => feedback_id}, _url, socket) do
    # feedback = Social.get_feedback(feedback_id)

    socket =
      socket
      |> assign(:feedback_id, feedback_id)
      |> assign_streamer(username)

    {:noreply, socket}
  end

  # Loads a specific streamer based on the given username
  # @live_action == :show_feedbacks
  def handle_params(%{"username" => username}, _url, socket) do
    socket = assign_streamer(socket, username)
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("flash", %{"level" => level, "message" => message}, socket) do
    Logger.debug("[BrandPageLive.handle_event.flash] message = #{message}")
    {:noreply, put_flash(socket, String.to_existing_atom(level), message)}
  end

  # def handle_event(event, params, socket) do
  #   Logger.error("[BrandPageLive.handle_event] #{event}, #{inspect(params)}")
  #   {:noreply, socket}
  # end

  @impl Phoenix.LiveView
  # PubSub notifications from TwitchLiveStreamers
  def handle_info({TwitchLiveStreamers, :online, %Streamer{} = streamer}, socket) do
    Logger.debug("[UserLive.online] #{streamer.display_name}")
    user = socket.assigns.streamer

    # check if streamer is displayed
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

  # PubSub notifications from TwitchLiveStreamers
  def handle_info({TwitchLiveStreamers, :offline, %Streamer{} = streamer}, socket) do
    Logger.debug("[UserLive.offline] #{streamer.display_name}")

    # check if streamer is displayed
    user = socket.assigns.streamer

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
  def handle_info({__MODULE__, :get_streaming_status, user}, socket) do
    Logger.debug("[BrandPageLive.get_streaming_status] #{user.username}")

    socket =
      with %TwitchUser{twitch_user_id: twitch_user_id} <- get_twitch_user_from_db(user.id) do
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

  # message sent by Notifications PubSub
  def handle_info({Notifications, :update, feedback, feedback_votes}, socket) do
    Logger.debug("[BrandPageLive.handle_info.Notifications.update] #{feedback.id}")

    # forward to LiveComponent
    send_update(self(), BrandPageComponent,
      id: socket.assigns.streamer.brand_page.id,
      updated_feedback: feedback,
      updated_feedback_votes: feedback_votes
    )

    {:noreply, socket}
  end

  ##########################################
  # Helper functions for data loading
  ##########################################

  defp assign_streamer(socket, username) do
    case Social.get_user_with_brand_page_by_username(username) do
      nil ->
        Logger.warning("[BrandPageLive.assign_streamer] no user found for #{username}")

        socket
        |> assign(:streamer, nil)
        |> assign_page_title(nil, username)

      %User{} = user ->
        # fetch online status from API in the background, see handle_info below
        if connected?(socket), do: send(self(), {__MODULE__, :get_streaming_status, user})

        Logger.debug("[BrandPageLive.assign_streamer] found user = #{username}")

        socket
        |> assign(:streamer, user)
        |> assign(:streaming_status, "loading")
        |> assign_page_title(user.brand_page, username)
        |> maybe_load_twitch_streamer(user)
    end
  end

  defp assign_page_title(socket, nil, username) do
    assign(socket, :page_title, username)
  end

  defp assign_page_title(socket, %BrandPage{} = brand_page, _username) do
    assign(socket, :page_title, brand_page.title)
  end

  # check if user is a twitch user, then subscribe to online events and
  # set socket.assigns
  defp maybe_load_twitch_streamer(socket, %User{id: user_id}) do
    with %TwitchUser{} = twitch_user <- get_twitch_user_from_db(user_id) do
      TwitchLiveStreamers.subscribe_to_streamer(twitch_user.twitch_user_id)
      assign(socket, :twitch_user, twitch_user)
    else
      _ -> socket
    end
  end

  defp maybe_load_twitch_streamer(socket, _), do: socket

  # TODO: demo purposes only 
  #
  # If the user is created automatically, we will return a
  # TwitchUser struct:
  #
  #   %TwitchUser{twitch_user_id: twitch_user_id}
  #
  # If the user is not a twitch broadcaster, returns nil
  defp get_twitch_user_from_db(user_id) do
    Poffee.Streaming.get_twitch_user_by_user_id(user_id)
  end

  ##########################################
  # Helper functions for HEEX rendering
  ##########################################
end
