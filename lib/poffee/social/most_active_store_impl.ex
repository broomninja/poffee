defmodule Poffee.Social.MostActiveStore.Impl do
  @moduledoc """
  Implementation for MostActiveStore
  """

  alias Poffee.Social
  alias Poffee.Social.MostActiveStore
  alias Poffee.Social.Notifications

  require Logger

  @default_limit 10

  defmodule State do
    @type t :: %State{
            most_active_by_feedbacks_count: list(BrandPage.t()),
            most_active_by_feedback_votes_count: list(BrandPage.t()),
            limit: Integer.t()
          }

    defstruct ~w(
      most_active_by_feedbacks_count
      most_active_by_feedback_votes_count
      limit
      )a
  end

  def fetch_initial_state(state) do
    Logger.debug("[MostActiveStore.Impl.fetch_initial_state] ")

    # subscribe to all feedback updates, MostActiveStore will receive notificaitons in handle_info
    Notifications.subscribe_all_feedbacks()

    # load from database
    state
    |> Map.merge(%{limit: @default_limit})
    |> update_state()
  end

  def get_most_active_by_feedbacks_count(state, limit) do
    state |> Map.get(:most_active_by_feedbacks_count) |> Enum.take(limit)
  end

  def get_most_active_by_feedback_votes_count(state, limit) do
    state |> Map.get(:most_active_by_feedback_votes_count) |> Enum.take(limit)
  end

  def update_and_broadcast(state) do
    Logger.debug("[MostActiveStore.Impl.update_and_broadcast]")

    limit = state |> Map.get(:limit)

    # TODO add rate limiting, only update and broadcast at most once every 10 secs

    # load from db
    state = update_state(state)

    payload =
      {MostActiveStore, :updated_most_active, get_most_active_by_feedbacks_count(state, limit),
       get_most_active_by_feedback_votes_count(state, limit)}

    Notifications.broadcast_most_active(payload)

    state
  end

  ################################################
  # Private/utility methods
  ################################################

  defp update_state(state) do
    limit = state |> Map.get(:limit)

    state
    |> Map.put(
      :most_active_by_feedbacks_count,
      Social.get_top_streamers_with_most_feedbacks(limit)
    )
    |> Map.put(
      :most_active_by_feedback_votes_count,
      Social.get_top_streamers_with_most_feedback_votes(limit)
    )
  end
end
