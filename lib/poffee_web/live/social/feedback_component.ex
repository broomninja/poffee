defmodule Poffee.Social.FeedbackComponent do
  use PoffeeWeb, :live_component

  alias Poffee.Utils

  require Logger

  @default_assigns %{}

  @impl Phoenix.LiveComponent
  def mount(socket) do
    {:ok, assign(socket, @default_assigns), temporary_assigns: []}
  end

  # @impl Phoenix.LiveComponent
  # def preload(list_of_assigns) do
  #   IO.inspect(list_of_assigns)
  #    list_of_assigns
  # end

  @impl Phoenix.LiveComponent
  def update(%{feedback: feedback, user_voted_list: user_voted_list} = assigns, socket) do
    Logger.debug("[FeedbackComponent.update.feedback] has_already_voted")

    has_already_voted = Enum.member?(user_voted_list, feedback.id)

    socket =
      socket
      |> assign(assigns)
      |> assign(:has_already_voted, has_already_voted)

    {:ok, socket}
  end

  def update(assigns, socket) do
    Logger.debug("[FeedbackComponent.update.default]")
    {:ok, socket |> assign(assigns)}
  end

  ##########################################
  # Helper functions for data loading
  ##########################################

  ##########################################
  # Helper functions for HEEX rendering
  ##########################################

  def get_container_id(id) do
    "feedback-#{id}"
  end

  attr :live_action, :atom, required: true
  attr :feedback, :map, required: true
  attr :brandpage_username, :string, required: true

  defp feedback_title(assigns) do
    ~H"""
    <div
      :if={@live_action == :show_feedbacks}
      class="col-span-7 ml-1 mb-2 text-lg font-bold text-gray-800 hover:text-blue-700 lg:leading-tight dark:text-white"
    >
      <.link navigate={~p"/u/#{@brandpage_username}/#{@feedback.id}"}>
        <%= @feedback.title %>
      </.link>
    </div>
    <div
      :if={@live_action == :show_single_feedback}
      class="col-span-7 ml-1 mb-2 text-lg font-bold text-gray-800 lg:leading-tight dark:text-white"
    >
      <%= @feedback.title %>
    </div>
    """
  end

  attr :feedback_votes, :list, required: true

  defp voters_list(assigns) do
    ~H"""
    <div class="ml-2 pl-3 pr-5 pt-2 pb-4 bg-slate-100 rounded-md">
      <div class="pl-1 pr-10 mb-2 font-semibold">Voters</div>
      <div :if={Utils.is_non_empty_list?(@feedback_votes)}>
        <.voter
          :for={feedback_vote <- @feedback_votes}
          username={feedback_vote.user.username}
          creation_time={feedback_vote.inserted_at}
        />
      </div>
      <div :if={!Utils.is_non_empty_list?(@feedback_votes)}>
        <div class="pl-1 text-sm text-gray-700">None</div>
      </div>
    </div>
    """
  end

  # Displays the voter name and time 
  attr :username, :string, required: true
  attr :creation_time, :string, required: true

  defp voter(assigns) do
    ~H"""
    <div class="flex pt-2 items-start justify-start text-sm whitespace-nowrap">
      <Petal.HeroiconsV1.Solid.user class="w-5 h-5 pb-[0.025rem]" />
      <div class="pl-1">
        <div class="font-semibold"><%= @username %></div>
        <div class="text-xs text-gray-700">
          <LiveSvelte.svelte
            name="DateTimeDisplay"
            props={%{prefix: "voted", datetime: @creation_time}}
          />
        </div>
      </div>
    </div>
    """
  end
end
