defmodule PoffeeWeb.FeedbackLive do
  use PoffeeWeb, :live_view

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

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""

    """
  end

  ##########################################
  # Helper functions for data loading
  ##########################################

  defp assign_streamer(socket, _username) do
    socket
  end
end
