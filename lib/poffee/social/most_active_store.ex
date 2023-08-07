defmodule Poffee.Social.MostActiveStore do
  @moduledoc """
  GenServer process keeping track of the most active streamers, subscribes to events
  and update the stored state
  """
  use GenServer

  alias Poffee.Social.Feedback
  alias Poffee.Social.MostActiveStore.Impl
  alias Poffee.Social.Notifications

  require Logger

  # 20 secs timeout
  @timeout :timer.seconds(20)

  ################################################
  # Client APIs
  ################################################

  def start_link(arg, opts \\ []) do
    server_name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, arg, name: server_name)
  end

  def get_most_active_by_feedbacks_count(pid \\ __MODULE__, limit) do
    GenServer.call(pid, {:get_most_active_by_feedbacks_count, limit}, @timeout)
  end

  def get_most_active_by_feedback_votes_count(pid \\ __MODULE__, limit) do
    GenServer.call(pid, {:get_most_active_by_feedback_votes_count, limit}, @timeout)
  end

  ################################################
  # Server callbacks
  ################################################

  @impl GenServer
  def init(_arg) do
    initial_state = %Impl.State{}
    {:ok, initial_state, {:continue, :fetch_initial_state}}
  end

  @impl GenServer
  def handle_continue(:fetch_initial_state, state) do
    {:noreply, Impl.fetch_initial_state(state)}
  end

  @impl GenServer
  def handle_call({:get_most_active_by_feedbacks_count, limit}, _from, state) do
    {:reply, Impl.get_most_active_by_feedbacks_count(state, limit), state}
  end

  def handle_call({:get_most_active_by_feedback_votes_count, limit}, _from, state) do
    {:reply, Impl.get_most_active_by_feedback_votes_count(state, limit), state}
  end

  @impl GenServer
  # Notifications from PubSub broadcast
  def handle_info({Notifications, :update, %Feedback{}}, state) do
    Logger.debug("[MostActiveStore.handle_info.update.feedback]")

    {:noreply, Impl.update_and_broadcast(state)}
  end

  def handle_info({Notifications, :update, %Feedback{}, list_of_feedback_votes}, state)
      when is_list(list_of_feedback_votes) do
    Logger.debug("[MostActiveStore.handle_info.update.feedback_votes]")

    {:noreply, Impl.update_and_broadcast(state)}
  end
end
