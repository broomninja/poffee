defmodule PoffeeWeb.StreamingLive do
  use PoffeeWeb, :live_view

  require Logger

  @default_max_streamers 10
  @sm_min_width 640
  @md_min_width 768
  # @lg_min_width 1024
  # @xl_min_width 1280

  @impl Phoenix.LiveView
  def mount(_params, session, socket) do
    socket =
      socket
      # |> PhoenixLiveSession.maybe_subscribe(session)
      # |> TwitchService.maybe_subscribe()
      |> put_session_assigns(session)

    # TODO remove
    if connected?(socket) do
      Process.send_after(self(), :simulate_new_streamer, 3_000)
    end

    {:ok, socket, layout: false, temporary_assigns: []}
  end

  defp put_session_assigns(socket, _session) do
    socket
    |> assign_new(:streamers, fn -> [] end)
    |> assign_new(:event, fn -> nil end)
  end

  # TODO remove
  defp create_streamer(num) do
    %{num: num}
  end

  # TODO remove
  defp get_streamers(socket) do
    1020..1001
    |> Enum.map(&create_streamer/1)
    |> maybe_apply_limit(Map.get(socket.assigns, :display_limit))
  end

  # TODO remove
  defp get_new_streamer(socket) do
    list = Map.get(socket.assigns, :streamers)
    max = Enum.max_by(list, & &1.num) |> Map.get(:num)
    create_streamer(max + 1)
  end

  # TODO remove
  defp add_streamer(socket, streamers) do
    [get_new_streamer(socket) | streamers]
    |> maybe_apply_limit(Map.get(socket.assigns, :display_limit))
  end

  defp maybe_apply_limit(list, limit) do
    limit = limit || @default_max_streamers

    if length(list) > limit do
      Enum.take(list, limit)
    else
      list
    end
  end

  defp get_display_limit(width) when is_integer(width) and width < @sm_min_width, do: 5
  defp get_display_limit(width) when is_integer(width) and width < @md_min_width, do: 7
  defp get_display_limit(_), do: @default_max_streamers

  @impl Phoenix.LiveView
  def handle_event("display_ready", _param, socket) do
    socket =
      socket
      |> assign(:streamers, get_streamers(socket))
      |> assign(:event, "update_streamer_list")

    {:noreply, socket}
  end

  def handle_event("window_width_change", window_width, socket) do
    limit = get_display_limit(window_width)

    socket =
      socket
      |> assign(:display_limit, limit)
      |> update(:streamers, &maybe_apply_limit(&1, limit))

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  # TODO remove
  def handle_info(:simulate_new_streamer, socket) do
    Process.send_after(self(), :simulate_new_streamer, 3_000)

    handle_event("add_streamer", nil, socket)
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="bg-gray-200 flex items-center justify-between px-5 md:px-10 h-14">
      <LiveSvelte.svelte
        name="StreamingList"
        ssr={false}
        props={%{event: @event, streamers: @streamers}}
      />
    </div>
    """
  end
end
