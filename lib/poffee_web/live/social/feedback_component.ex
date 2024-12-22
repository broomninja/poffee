defmodule Poffee.Social.FeedbackComponent do
  use PoffeeWeb, :live_component

  alias Poffee.Accounts.User
  alias Poffee.Constant
  alias Poffee.Social
  alias Poffee.Utils

  require Logger

  @default_assigns %{
    sort_by_options: [
      Oldest: "oldest",
      Newest: "newest"
    ],
    sort_by_form: to_form(%{}, as: "sort_by_form")
  }

  @impl Phoenix.LiveComponent
  def mount(socket) do
    {:ok, assign(socket, @default_assigns), temporary_assigns: []}
  end

  @impl Phoenix.LiveComponent
  # update invoked from BrandPageComponent.html.heex
  def update(%{feedback: feedback, user_voted_list: user_voted_list} = assigns, socket) do
    Logger.debug("[FeedbackComponent.update.feedback] has_already_voted: #{feedback.id}")

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

  @impl Phoenix.LiveComponent
  # called from CreateComment.svelte
  def handle_event(
        "create_comment",
        %{"content" => comment_content, "user_id" => user_id, "feedback_id" => feedback_id},
        socket
      )
      when not is_nil(user_id) do
    Logger.debug("[FeedbackComponent.handle_event.create_comment] user_id = #{user_id}")

    create_result = Social.create_comment(%{content: comment_content}, user_id, feedback_id)

    socket =
      case create_result do
        {:ok, _comment} ->
          # put_flash will not work when we are in the LC, so forward the flash
          # message to the parent LV
          send(self(), {__MODULE__, :flash, %{level: :info, message: "Comment created!"}})

          paginated_comments =
            Social.get_comments_by_feedback_id(feedback_id, socket.assigns.params)

          comments = paginated_comments.entries
          pagination_meta = Map.delete(paginated_comments, :entries)

          socket
          |> assign(:comments, comments)
          |> assign(:pagination_meta, pagination_meta)

        _ ->
          send(
            self(),
            {__MODULE__, :flash, %{level: :error, message: "Error when creating comment!"}}
          )

          socket
      end

    {:reply, %{create_comment_reply: Map.new([create_result])}, socket}
  end

  def handle_event("create_comment", _, socket) do
    Logger.warning("[FeedbackComponent.handle_event.create_comment] user_id is nil")
    {:reply, %{create_comment_reply: %{error: "User not logged in"}}, socket}
  end

  ##########################################
  # Helper functions for data loading
  ##########################################

  ##########################################
  # Helper functions for HEEX rendering
  ##########################################

  defp get_container_id(feedback_id) do
    "feedback-#{feedback_id}"
  end

  defp get_create_comment_container_id(feedback_id) do
    "create-comment-#{feedback_id}"
  end

  # show the login modal if user is not logged in,
  # otherwise show the create form
  defp maybe_toggle_create_comment_form(js \\ %JS{}, user, feedback_id)

  defp maybe_toggle_create_comment_form(_js, nil, _feedback_id) do
    show_modal("live-login-modal")
  end

  defp maybe_toggle_create_comment_form(js, %User{}, feedback_id) do
    js
    |> JS.toggle(
      to: "#" <> get_create_comment_container_id(feedback_id),
      in: {"ease-out duration-300", "opacity-0", "opacity-100"},
      out: {"ease-in duration-300", "opacity-100", "opacity-0"}
    )
  end

  defp hide_create_comment_form(js \\ %JS{}, feedback_id) do
    js
    |> JS.hide(to: "#" <> get_create_comment_container_id(feedback_id))
  end

  attr :live_action, :atom, required: true
  attr :feedback, :map, required: true
  attr :brandpage_username, :string, required: true

  defp feedback_title(assigns) do
    ~H"""
    <div
      :if={@live_action == :show_feedbacks}
      class="col-span-7 ml-1 mb-2 text-lg font-bold text-gray-800 hover:text-blue-700 lg:leading-tight"
    >
      <.link navigate={~p"/u/#{@brandpage_username}/#{@feedback.id}"}>
        <%= @feedback.title %>
      </.link>
    </div>
    <div
      :if={@live_action == :show_single_feedback}
      class="col-span-7 ml-1 mb-2 text-lg font-bold text-gray-800 lg:leading-tight"
    >
      <%= @feedback.title %>
    </div>
    """
  end

  attr :feedback_votes, :list, required: true

  defp voters_list(assigns) do
    ~H"""
    <div class="flex flex-col min-w-[185px] ml-2 pl-3 pr-5 pt-2 pb-4 bg-slate-100 rounded-md">
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
            name="DateTimeLiveDisplay"
            props={%{prefix: "voted", datetime: @creation_time}}
          />
        </div>
      </div>
    </div>
    """
  end
end
