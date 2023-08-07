defmodule Poffee.Social.Notifications do
  @moduledoc """
  Handles the subscription and broadcast of updates to the data model.
  """
  require Logger

  @topic_feedback "topic_feedback"
  @topic_most_active "topic:most_active"

  ###########################
  # Subscirption
  ###########################

  # subscribe to all feedbacks
  def subscribe_all_feedbacks() do
    Logger.debug("[Notifications.subscribe_all_feedbacks] ")

    # unsubcribe first to clear any existing subscriptions, to avoid any duplicates
    Phoenix.PubSub.unsubscribe(Poffee.PubSub, @topic_feedback)
    Phoenix.PubSub.subscribe(Poffee.PubSub, @topic_feedback)
  end

  # subscribe to a specific feedback
  def subscribe_feedback(feedback_id) do
    Logger.debug("[Notifications.subscribe_feedback] #{feedback_id}")
    topic = @topic_feedback <> ".#{feedback_id}"

    # unsubcribe first to clear any existing subscriptions, to avoid any duplicates
    Phoenix.PubSub.unsubscribe(Poffee.PubSub, topic)
    Phoenix.PubSub.subscribe(Poffee.PubSub, topic)
  end

  # unsubscribe to a specific feedback
  def unsubscribe_feedback(feedback_id) do
    Logger.debug("[Notifications.unsubscribe_feedback] #{feedback_id}")
    topic = @topic_feedback <> ".#{feedback_id}"
    Phoenix.PubSub.unsubscribe(Poffee.PubSub, topic)
  end

  # subscribe to most active store
  def subscribe_most_active() do
    Logger.debug("[Notifications.subscribe_most_active] ")

    # unsubcribe first to clear any existing subscriptions, to avoid any duplicates
    Phoenix.PubSub.unsubscribe(Poffee.PubSub, @topic_most_active)
    Phoenix.PubSub.subscribe(Poffee.PubSub, @topic_most_active)
  end

  ###########################
  # Broadcast
  ###########################

  # broadcast the updated feedback and feedback_votes
  def broadcast_feedback(feedback) do
    Logger.debug("[Notifications.broadcast_feedback] id #{feedback.id}")

    payload = {__MODULE__, :update, feedback}
    broadcast_feedback_to_all(@topic_feedback, @topic_feedback <> ".#{feedback.id}", payload)
  end

  # broadcast the updated feedback and feedback_votes
  def broadcast_feedback_and_votes(feedback, feedback_votes) do
    Logger.debug("[Notifications.broadcast_feedback_and_votes] id #{feedback.id}")

    payload = {__MODULE__, :update, feedback, feedback_votes}
    broadcast_feedback_to_all(@topic_feedback, @topic_feedback <> ".#{feedback.id}", payload)
  end

  defp broadcast_feedback_to_all(all_topic, individual_topic, payload) do
    # broadcast to all
    Phoenix.PubSub.broadcast(Poffee.PubSub, all_topic, payload)

    # broadcast to individual feedback subscribers
    Phoenix.PubSub.broadcast(Poffee.PubSub, individual_topic, payload)

    :ok
  end

  def broadcast_most_active(payload) do
    Phoenix.PubSub.broadcast(Poffee.PubSub, @topic_most_active, payload)
  end
end
