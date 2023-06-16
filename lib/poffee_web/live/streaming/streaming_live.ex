defmodule PoffeeWeb.StreamingLive do
  use PoffeeWeb, :live_view

  require Logger

  @impl Phoenix.LiveView
  def mount(_params, session, socket) do
    socket =
      socket
      # |> PhoenixLiveSession.maybe_subscribe(session)
      |> put_session_assigns(session)

    {:ok, socket, layout: false, temporary_assigns: []}
  end

  defp put_session_assigns(socket, _session) do
    socket
    |> assign(number: 15)
  end

  @impl Phoenix.LiveView
  def handle_event("set_number", %{"number" => number}, socket) do
    {:noreply, assign(socket, :number, number)}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="bg-red-200">
      <LiveSvelte.svelte name="Number" props={%{number: @number}} />
    </div>
    """
  end
end
