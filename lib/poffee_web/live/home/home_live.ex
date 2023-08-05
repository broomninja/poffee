defmodule PoffeeWeb.HomeLive do
  use PoffeeWeb, :live_view

  require Logger

  @impl Phoenix.LiveView
  def mount(_params, session, socket) do
    socket =
      socket
      |> PhoenixLiveSession.maybe_subscribe(session)
      |> maybe_put_session_assigns(session)
      |> assign_new(:page_title, fn -> "Home" end)
      |> assign_new(:current_user, fn -> nil end)
      |> assign_new(:somevalue, fn -> nil end)
      |> assign_new(:number, fn -> 5 end)
      |> assign_new(:selected_fruit, fn -> nil end)
      |> assign_new(:selected_time, fn -> nil end)

    {:ok, socket}
  end

  defp maybe_put_session_assigns(socket, session) do
    # always fetch from PhoenixLiveSession, the plug session can become outdated since we are 
    # not going through the plug when using liveview navigate which bypasses the plug

    if connected?(socket) do
      sid = Map.get(session, :__sid__)
      opts = Map.get(session, :__opts__)

      {_sid, phoenix_live_session} = PhoenixLiveSession.get(nil, sid, opts)

      socket
      |> assign(:selected_fruit, Map.get(phoenix_live_session, "selected_fruit", "empty"))
      |> assign(:selected_time, Map.get(phoenix_live_session, "selected_time", "empty"))
    else
      socket
    end
  end

  @impl Phoenix.LiveView
  def handle_event("select-fruit", %{"fruit" => fruit}, socket) do
    PhoenixLiveSession.put_session(socket, "selected_fruit", fruit)
    PhoenixLiveSession.put_session(socket, "selected_time", Timex.now())
    {:noreply, socket}
  end

  def handle_event("set_number", %{"number" => number}, socket) do
    {:noreply, assign(socket, :number, number)}
  end

  @impl Phoenix.LiveView
  def handle_info({:live_session_updated, session}, socket) do
    {:noreply, maybe_put_session_assigns(socket, session)}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="px-10 md:px-20 pt-3 pb-5">
      <pre>
    Quick Guide:

    - Click on any of the profile icons above, a real-time display of streamers currently streaming live on Twitch.

    - After login, users will be able to create feedbacks and reply with comments.

    Main features implemented:
    [x] User login and registration
    [x] Twitch API connection and subscription on streamer events
    [x] Create Feedbacks and Comments
    [x] Vote count and voter list will update in real-time for all users (via PubSub) 
    [x] Time displayed is real-time and auto updated without page reloading (LiveSvelte)
    [x] Basic user search (username only)
    [x] Most Active lists

    To be implemented:
    [ ] Notification feed on new feedbacks, comments, votes etc for all users
    [ ] Sorting and Pagination
      </pre>
    </div>
    """
  end
end
