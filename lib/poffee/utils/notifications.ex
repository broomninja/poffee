defmodule Poffee.Notifications do
  @moduledoc """
  Handles the subscription and broadcast of updates to the data model.
  """
  require Logger

  @topic_feedback "topic_feedback"

  # subscribe to all feedbacks
  def subscribe_all_feedbacks() do
    Logger.debug("[Notification.subscribe_all_feedbacks] ")
    Phoenix.PubSub.subscribe(Poffee.PubSub, @topic_feedback)
  end

  # subscribe to a specific feedback
  def subscribe_feedback(feedback_id) do
    Logger.debug("[Notification.subscribe_feedback] #{feedback_id}")
    topic = @topic_feedback <> ".#{feedback_id}"

    # always unsubcribe first to clear any existing subscriptions, to avoid any duplicates
    Phoenix.PubSub.unsubscribe(Poffee.PubSub, topic)
    Phoenix.PubSub.subscribe(Poffee.PubSub, topic)
  end

  # unsubscribe to a specific feedback
  def unsubscribe_feedback(feedback_id) do
    Logger.debug("[Notification.unsubscribe_feedback] #{feedback_id}")
    topic = @topic_feedback <> ".#{feedback_id}"
    Phoenix.PubSub.unsubscribe(Poffee.PubSub, topic)
  end

  # broadcast the updated feedback
  def broadcast_feedback(feedback) do
    Logger.debug("[Notification.broadcast_feedback] id #{feedback.id}")

    # broadcast to all
    Phoenix.PubSub.broadcast(Poffee.PubSub, @topic_feedback, {__MODULE__, :update, feedback})

    # broadcast to individual feedback subscribers
    Phoenix.PubSub.broadcast(
      Poffee.PubSub,
      @topic_feedback <> ".#{feedback.id}",
      {__MODULE__, :update, feedback}
    )
  end
end
