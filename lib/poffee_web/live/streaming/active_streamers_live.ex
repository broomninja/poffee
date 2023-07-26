defmodule PoffeeWeb.ActiveStreamersLive do
  use PoffeeWeb, :live_view

  require Logger

  @impl Phoenix.LiveView
  def mount(_params, session, socket) do
    socket =
      socket
      # |> PhoenixLiveSession.maybe_subscribe(session)
      |> put_session_assigns(session)
      |> assign_new(:number, fn -> 15 end)

    {:ok, socket, layout: false, temporary_assigns: []}
  end

  defp put_session_assigns(socket, _session) do
    # we defer the display of streamers after we have received the first "window_width_change" 
    # event from liveview client. See handle_event("window_width_change", ...) below.
    socket
  end

  @impl Phoenix.LiveView
  def handle_event("set_number", %{"number" => number}, socket) do
    {:noreply, assign(socket, :number, number)}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="bg-gray-200 flex items-center justify-between px-5 xl:px-8 py-1">
      Most Active Streamers
      <div></div>
    </div>
    """
  end
end
