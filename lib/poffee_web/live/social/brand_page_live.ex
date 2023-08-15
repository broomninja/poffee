defmodule PoffeeWeb.BrandPageLive do
  use PoffeeWeb, :live_view

  alias Poffee.Accounts.User
  alias Poffee.Social.Notifications
  alias Poffee.Social
  alias Poffee.Social.BrandPage
  alias Poffee.Social.BrandPageComponent
  alias Poffee.Social.CreateFeedbackComponent
  alias Poffee.Streaming.{TwitchUser, TwitchApiConnector, TwitchLiveStreamers}
  alias Poffee.Streaming.Twitch.Streamer
  alias Poffee.Utils

  import Ecto.Changeset, only: [apply_changes: 1, cast: 3]

  require Logger

  @default_assigns %{
    feedback_id: nil,
    twitch_user: nil,
    streaming_status: "blank"
  }

  @impl Phoenix.LiveView
  def mount(params, %{"remote_ip" => remote_ip} = _session, socket) do
    user_agent = get_connect_info(socket, :user_agent)

    Logger.info(
      "[BrandPageLive.mount] REMOTE_IP: #{remote_ip}, UA: #{user_agent}, params: #{inspect(params)}"
    )

    {:ok, assign(socket, @default_assigns), temporary_assigns: []}
  end

  @impl Phoenix.LiveView
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl Phoenix.LiveView
  # display flash messages from LiveSvelte pushEvent()
  def handle_event("flash", %{"level" => level, "message" => message}, socket) do
    Logger.debug("[BrandPageLive.handle_event.flash] message = #{message}")
    {:noreply, put_flash(socket, String.to_existing_atom(level), message)}
  end

  # changing sort_by will always reset "page" to 1
  def handle_event("sort_by_update", %{"sort_by_form" => sort_by_params}, socket) do
    Logger.debug(
      "[BrandPageLive.handle_event.sort_by_update] sort_by_form = #{inspect(sort_by_params)}"
    )

    socket =
      sort_by_params
      |> sort_by_changeset()
      |> case do
        %{valid?: true} = changeset ->
          new_sort_by_attrs = Utils.stringify_keys(apply_changes(changeset))
          # remove "page" param if any, so it will default to page 1
          new_params =
            socket.assigns.params
            |> Map.merge(new_sort_by_attrs)
            |> Map.delete("page")

          socket
          |> assign_params(new_params)
          |> then(fn s ->
            # reference the latest sockets.assigns.params updated by assign_params above using get_in/2
            push_navigate_to_self(
              s,
              socket.assigns.live_action,
              socket.assigns.streamer.username,
              socket.assigns.feedback_id,
              get_in(Map.from_struct(s), [:assigns, :params])
            )
          end)

        _ ->
          socket
      end

    {:noreply, socket}
  end

  def handle_event(event_name, params, socket) do
    Logger.error(
      "[BrandPageLive.handle_event] Unknown event: #{event_name}, params: #{inspect(params)}"
    )

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  # PubSub notifications from TwitchLiveStreamers
  def handle_info({TwitchLiveStreamers, :online, %Streamer{} = streamer}, socket) do
    Logger.debug("[BrandPageLive.handle_info.online] #{streamer.display_name}")
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
    Logger.debug("[BrandPageLive.handle_info.offline] #{streamer.display_name}")

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
    Logger.debug("[BrandPageLive.handle_info.get_streaming_status] #{user.username}")

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

  # flash messages from child LiveComponents
  def handle_info({_module, :flash, %{level: level, message: message}}, socket) do
    Logger.debug("[BrandPageLive.handle_info.flash] #{message}")
    {:noreply, put_flash(socket, level, message)}
  end

  # from child LiveComponent CreateFeedbackComponent after a new feedback has been created
  # simply remount this liveview which will determine if we need to load the new feedback
  # according to the sorting
  def handle_info(
        {CreateFeedbackComponent, :new_feedback_created_refresh, %{flash_message: message}},
        socket
      ) do
    Logger.debug("[BrandPageLive.handle_info.new_feedback_created_refresh]")

    {:noreply,
     socket
     |> put_flash(:info, message)
     |> push_navigate(to: socket.assigns.current_uri)}
  end

  # message sent by Notifications PubSub
  def handle_info({Notifications, :update, feedback, feedback_votes}, socket) do
    Logger.debug("[BrandPageLive.handle_info.Notifications.update] #{feedback.id}")

    # forward to child LiveComponent
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

  # @live_action == :show_single_feedback
  defp apply_action(socket, :show_single_feedback, %{"feedback_id" => feedback_id} = params) do
    socket
    |> assign(:feedback_id, feedback_id)
    |> assign_common(params)
  end

  # @live_action == :show_feedbacks
  defp apply_action(socket, :show_feedbacks, params) do
    assign_common(socket, params)
  end

  defp assign_common(socket, %{"username" => username} = params) do
    socket
    |> assign_streamer(username)
    |> assign_params(params)
  end

  # Loads a specific streamer based on the given username
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

  # only allow "page" and "sort_by" in socket.assigns.params
  # the value be passed as options when retrieving data from database
  defp assign_params(socket, params) do
    socket =
      socket
      |> assign_sort_by(params)
      |> assign_page(params)

    # reference the latest updated by assign_sort_by and assign_page above.
    # value of "page" will be stored as an integer instead of a string
    new_params =
      ["sort_by", "page"]
      |> Map.new(fn p ->
        {p, get_in(Map.from_struct(socket), [:assigns, String.to_existing_atom(p)])}
      end)

    Logger.debug("[BrandPageLive.assign_params] assigning new params = #{inspect(new_params)}")

    assign(socket, :params, new_params)
  end

  defp assign_sort_by(socket, %{"sort_by" => sort_by}) do
    Logger.debug("[BrandPageLive.assign_sort_by] selected sort_by: #{sort_by}")
    assign(socket, :sort_by, sort_by)
  end

  defp assign_sort_by(socket, _params) do
    default = Poffee.Constant.feedback_default_sort_by()
    Logger.debug("[BrandPageLive.assign_sort_by] default sort_by: #{inspect(default)}")
    assign(socket, :sort_by, default)
  end

  # Only positive integers will be stored in socket.assigns.page
  defp assign_page(socket, %{"page" => page}) when is_integer(page) and page > 0 do
    assign(socket, :page, page)
  end

  defp assign_page(socket, %{"page" => page}) do
    Logger.debug("[BrandPageLive.assign_page] selected page: #{page}")

    case Integer.parse(page) do
      {num, ""} ->
        assign(socket, :page, num)

      _ ->
        assign_page(socket, nil)
    end
  end

  defp assign_page(socket, _params) do
    Logger.debug("[BrandPageLive.assign_page] default page to 1")
    assign(socket, :page, 1)
  end

  defp sort_by_changeset(%{} = attrs) do
    cast({%{}, %{sort_by: :string}}, attrs, [:sort_by])
  end

  defp self_path(socket, :show_feedbacks = action, username, _feedback_id, query_string_attrs) do
    Logger.debug(
      "[BrandPageLive.self_path.show_feedbacks] query_string_attrs = #{inspect(query_string_attrs)}"
    )

    route = Routes.brand_page_path(socket, action, username, query_string_attrs)
    Logger.debug("[BrandPageLive.self_path.show_feedbacks] new route = #{route}")
    route
  end

  defp self_path(
         socket,
         :show_single_feedback = action,
         username,
         feedback_id,
         query_string_attrs
       ) do
    Logger.debug(
      "[BrandPageLive.self_path.show_single_feedbacks] query_string_attrs = #{inspect(query_string_attrs)}"
    )

    route = Routes.brand_page_path(socket, action, username, feedback_id, query_string_attrs)
    Logger.debug("[BrandPageLive.self_path.show_single_feedbacks] new route = #{route}")
    route
  end

  # we must use push_navigate instead of push_patch because we need UserLoginLive to be
  # re-mounted to include the query string param for user_return_to after user login redirection
  defp push_navigate_to_self(socket, action, username, feedback_id, query_string_attrs) do
    push_navigate(socket,
      to: self_path(socket, action, username, feedback_id, query_string_attrs)
    )
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
