defmodule PoffeeWeb.StreamingLive do
  use PoffeeWeb, :live_view

  alias Poffee.Streaming.TwitchLiveStreamers

  require Logger

  @sm_min_width 640
  @md_min_width 768
  @lg_min_width 1024
  @xl_min_width 1280

  @impl Phoenix.LiveView
  def mount(_params, session, socket) do
    socket =
      socket
      # |> PhoenixLiveSession.maybe_subscribe(session)
      |> put_session_assigns(session)

    if connected?(socket) do
      TwitchLiveStreamers.subscribe()
    end

    {:ok, socket, layout: false, temporary_assigns: []}
  end

  defp put_session_assigns(socket, _session) do
    # we defer the display of streamers after we have received the first "window_width_change" 
    # event from liveview client. See handle_event("window_width_change", ...) below.
    socket
    |> assign_new(:streamers, fn -> [] end)
    |> assign_new(:event, fn -> nil end)
  end

  defp maybe_apply_limit(nil, _limit), do: []
  defp maybe_apply_limit([], _limit), do: []

  defp maybe_apply_limit(list, limit) when is_list(list) do
    limit = limit || @default_max_streamers

    if length(list) > limit do
      Enum.take(list, limit)
    else
      list
    end
  end

  defp get_display_limit(width) when is_integer(width) and width < @sm_min_width, do: 5
  defp get_display_limit(width) when is_integer(width) and width < @md_min_width, do: 7
  defp get_display_limit(width) when is_integer(width) and width < @lg_min_width, do: 9
  defp get_display_limit(width) when is_integer(width) and width < @xl_min_width, do: 12
  defp get_display_limit(_), do: 14

  @impl Phoenix.LiveView
  def handle_event("window_width_change", window_width, socket) do
    limit = get_display_limit(window_width)

    socket =
      socket
      |> assign(:display_limit, limit)
      |> assign(:streamers, maybe_apply_limit(TwitchLiveStreamers.current_streamers(), limit))
      |> assign(:event, "update_streamers")

    {:noreply, socket}
  end

  # we subscribe to PubSub topic for new streamer events
  @impl Phoenix.LiveView
  def handle_info({:added_streamers, streamers}, socket) do
    socket =
      socket
      |> assign(:streamers, maybe_apply_limit(streamers, Map.get(socket.assigns, :display_limit)))
      |> assign(:event, "add_streamer")

    {:noreply, socket}
  end

  def handle_info({:updated_streamers, streamers}, socket) do
    socket =
      socket
      |> assign(:streamers, maybe_apply_limit(streamers, Map.get(socket.assigns, :display_limit)))
      |> assign(:event, "update_streamers")

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="bg-gray-200 flex items-center justify-between px-5 xl:px-8 h-16">
      <LiveSvelte.svelte
        name="StreamingList"
        ssr={false}
        props={%{event: @event, streamers: @streamers}}
      />
    </div>
    """
  end
end
