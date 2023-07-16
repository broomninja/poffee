defmodule Poffee.Social.FeedbackComponent do
  use PoffeeWeb, :live_component

  require Logger

  @default_assigns %{
    test_voter_count: 3
  }

  @impl Phoenix.LiveComponent
  def mount(socket) do
    {:ok, assign(socket, @default_assigns), temporary_assigns: []}
  end

  @impl Phoenix.LiveComponent
  def handle_event("vote", %{"user_id" => user_id, "feedback_id" => feedback_id}, socket)
      when not is_nil(user_id) do
    Logger.debug("[FeedbackComponent.handle_event.vote] user_id = #{user_id}")
    new_feedback = socket.assigns.feedback

    {:noreply, assign(socket, :feedback, new_feedback)}
  end

  def handle_event("vote", _, socket) do
    Logger.warning("[FeedbackComponent.handle_event.vote] user_id is nil")
    {:noreply, socket}
  end

  def handle_event(
        "unvote",
        %{"user_id" => user_id, "feedback_id" => feedback_id, "vote_id" => vote_id},
        socket
      )
      when not is_nil(user_id) do
    Logger.debug("[FeedbackComponent.handle_event.unvote] user_id = #{user_id}")
    new_feedback = socket.assigns.feedback
    {:noreply, assign(socket, :feedback, new_feedback)}
  end

  def handle_event("unvote", _, socket) do
    Logger.warning("[FeedbackComponent.handle_event.unvote] user_id is nil")
    {:noreply, socket}
  end

  ##########################################
  # Helper functions for HEEX rendering
  ##########################################

  # Get the relative time from now, nil if datetime is not in the correct format
  defp format_time(datetime) do
    with {:ok, relative_str} <- Timex.format(datetime, "{relative}", :relative) do
      relative_str
    end
  end

  def get_container_id(id) do
    "feedback-#{id}"
  end
end
