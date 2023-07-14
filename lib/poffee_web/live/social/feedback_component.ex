defmodule Poffee.Social.FeedbackComponent do
  use PoffeeWeb, :live_component

  require Logger

  @default_assigns %{
    user_vote: nil,
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

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div id={get_container_id(@id)} class="pt-5" data-show-login={show_modal("live-login-modal")}>
      <!-- Feedback -->
      <div class="grid grid-cols-9 gap-1 pt-4 pb-4 pl-2 bg-gray-100 rounded-md">
        <!-- Feedback title -->
        <div class="col-span-7 ml-1 mb-1 text-lg font-bold text-gray-800 lg:leading-tight dark:text-white">
          <%= @feedback.title %>
        </div>
        <!-- End Feedback title -->
        <!-- Vote Counter -->
        <div class="col-span-2 row-span-2 text-right">
          <LiveSvelte.svelte
            name="VoteCounter"
            ssr={false}
            props={
              %{
                current_user: @current_user,
                feedback: @feedback,
                test_voter_count: @test_voter_count,
                user_vote: @user_vote
              }
            }
          />
        </div>
        <!-- End Vote Counter -->
        <!-- Author -->
        <div class="col-span-7 ml-1">
          <%= @feedback.author_id %>
        </div>
        <!-- End Author -->
        <!-- Feedback content -->
        <div class="col-span-9 mt-3 ml-1 pr-5 text-sm text-gray-800">
          <%= @feedback.content %>
        </div>
        <!-- End Feedback content -->
        <!-- Created time -->
        <div class="col-span-7 mt-3 flex whitespace-nowrap text-gray-700 text-sm">
          <Petal.HeroiconsV1.Solid.clock class="w-6 h-6 pb-[0.025rem]" />
          <span class="pl-1">created <%= format_time(@feedback.inserted_at) %></span>
        </div>
        <!-- End Created time -->
      </div>
      <!-- End Feedback -->
    </div>
    """
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
