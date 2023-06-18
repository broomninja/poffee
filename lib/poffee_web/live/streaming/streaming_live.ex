defmodule PoffeeWeb.StreamingLive do
  use PoffeeWeb, :live_view

  require Logger

  @max_streamers 10

  @impl Phoenix.LiveView
  def mount(_params, session, socket) do
    socket =
      socket
      # |> PhoenixLiveSession.maybe_subscribe(session)
      |> put_session_assigns(session)

    if connected?(socket) do
      Process.send_after(self(), :simulate_new_streamer, 10_000)
    end

    {:ok, socket, layout: false, temporary_assigns: []}
  end

  defp put_session_assigns(socket, _session) do
    socket
    |> assign(:streamers, get_streamers())
    |> assign(:event, "update_streamer_list")
  end

  defp create_streamer(num) do
    %{num: num}
  end

  defp get_streamers do
    [4, 3, 2, 1]
    |> Enum.map(&create_streamer/1)
  end

  defp get_new_streamer(socket) do
    list = Map.get(socket.assigns, :streamers)
    max = Enum.max_by(list, & &1.num) |> Map.get(:num)
    create_streamer(max + 1)
  end

  defp add_streamer(socket, streamers) do
    new_list = [get_new_streamer(socket) | streamers]

    if length(new_list) > @max_streamers do
      List.delete_at(new_list, -1)
    else
      new_list
    end
  end

  @impl Phoenix.LiveView
  def handle_event("add_streamer", _params, socket) do
    socket =
      socket
      |> update(:streamers, &add_streamer(socket, &1))
      |> assign(:event, "add_streamer")

    Logger.debug("[add_streamer] socket.assigns: #{inspect(socket.assigns.streamers)}")

    {:noreply, socket}
  end

  def handle_event("update_streamer_list", _params, socket) do
    socket =
      socket
      |> update(:streamers, &random_update/1)
      |> assign(:event, "update_streamer_list")

    Logger.debug("[update_streamer_list] socket.assigns: #{inspect(socket.assigns.streamers)}")

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_info(:simulate_new_streamer, socket) do
    Process.send_after(self(), :simulate_new_streamer, 10_000)

    handle_event("add_streamer", nil, socket)
  end

  defp random_update(streamers) do
    index = Enum.random(1..length(streamers)) - 1
    Logger.debug("[random_update] index = #{index}")
    res = List.update_at(streamers, index, &create_streamer(&1.num + 10))
    Logger.debug("[random_update] res = #{inspect(res)}")
    res
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="bg-gray-200 py-3 px-5 md:px-10">
      <LiveSvelte.svelte name="StreamingList" props={%{event: @event, streamers: @streamers}} />
    </div>
    """
  end
end
