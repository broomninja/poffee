defmodule Poffee.Social.BrandPageComponent do
  use PoffeeWeb, :live_component

  alias Poffee.Notifications
  alias Poffee.Social
  alias Poffee.Social.Feedback
  alias Poffee.Utils

  require Logger

  # @default_page_size 3

  @impl Phoenix.LiveComponent
  def preload([%{live_action: :show_feedbacks} = assigns]) do
    brand_page_id = assigns.streamer.brand_page.id

    Logger.debug(
      "[BrandPageComponent.preload] loading feedbacks for brand_page_id #{inspect(brand_page_id)}"
    )

    feedbacks =
      Social.get_feedbacks_with_comments_count_and_voters_count_by_brand_page_id(brand_page_id)

    subscribe_for_notifications(feedbacks)

    [
      Map.merge(assigns, %{
        page: 1,
        feedbacks: feedbacks
      })
    ]
  end

  def preload([%{live_action: :show_single_feedback} = assigns]) do
    Logger.debug(
      "[BrandPageComponent.preload] loading feedback for feedback_id #{inspect(assigns.feedback_id)}"
    )

    feedback_id = assigns.feedback_id
    feedback = Social.get_feedback_with_comments_count_and_voters_count_by_id(feedback_id)

    if is_nil(feedback) do
      Logger.warn("[BrandPageComponent.preload] Feedback not found for id #{assigns.feedback_id}")
    end

    comments = Social.get_comments_by_feedback_id(feedback_id)
    feedback_votes = Social.get_feedback_votes_by_feedback_id(feedback_id)
    subscribe_for_notifications(feedback)

    [
      Map.merge(assigns, %{
        feedback: feedback,
        comments: comments,
        feedback_votes: feedback_votes
      })
    ]
  end

  def preload(list_of_assigns), do: list_of_assigns

  @impl Phoenix.LiveComponent
  def mount(socket) do
    Logger.debug(
      "[BrandPageComponent.mount] pid = #{inspect(self())} socket connected? #{connected?(socket)}"
    )

    socket
    |> assign_new(:comments, fn -> nil end)
    |> assign_new(:feedback_votes, fn -> nil end)

    {:ok, socket, temporary_assigns: []}
  end

  @impl Phoenix.LiveComponent
  def update(%{updated_feedback: feedback, updated_feedback_votes: feedback_votes}, socket) do
    Logger.debug(
      "[BrandPageComponent.update.updated_feedback] live_action = #{inspect(socket.assigns.live_action)}"
    )

    socket =
      case socket.assigns.live_action do
        # replace the old feedback in assigns
        :show_feedbacks ->
          feedbacks =
            socket.assigns.feedbacks
            |> Enum.map(fn
              fb when fb.id == feedback.id -> feedback
              fb -> fb
            end)

          assign(socket, feedbacks: feedbacks)

        :show_single_feedback ->
          socket
          |> maybe_assign_feedback(feedback, feedback_votes)
      end

    {:ok, socket}
  end

  # default update callback
  def update(assigns, socket) do
    # Logger.error("[BrandPageComponent.update.default] assigns #{inspect(assigns)}")
    Logger.debug(
      "[BrandPageComponent.update.default] live_action = #{inspect(assigns.live_action)}"
    )

    {:ok, socket |> assign(assigns)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("vote", %{"user_id" => user_id, "feedback_id" => feedback_id}, socket)
      when not is_nil(user_id) do
    Logger.debug("[BrandPageComponent.handle_event.vote] user_id = #{user_id}")
    Social.vote_feedback(user_id, feedback_id)
    {:noreply, socket}
  end

  def handle_event("vote", _, socket) do
    Logger.warning("[BrandPageComponent.handle_event.vote] user_id is nil")
    {:noreply, socket}
  end

  def handle_event("unvote", %{"user_id" => user_id, "feedback_id" => feedback_id}, socket)
      when not is_nil(user_id) do
    Logger.debug("[BrandPageComponent.handle_event.unvote] user_id = #{user_id}")
    Social.unvote_feedback(user_id, feedback_id)
    {:noreply, socket}
  end

  def handle_event("unvote", _, socket) do
    Logger.warning("[BrandPageComponent.handle_event.unvote] user_id is nil")
    {:noreply, socket}
  end

  def handle_event("subscribe_feedback", %{"feedback_id" => feedback_id}, socket) do
    Logger.debug(
      "[BrandPageComponent.handle_event.subscribe_feedback] feedback_id = #{feedback_id}"
    )

    Notifications.subscribe_feedback(feedback_id)
    {:noreply, socket}
  end

  def handle_event("unsubscribe_feedback", %{"feedback_id" => feedback_id}, socket) do
    Logger.debug(
      "[BrandPageComponent.handle_event.unsubscribe_feedback] feedback_id = #{feedback_id}"
    )

    Notifications.unsubscribe_feedback(feedback_id)
    {:noreply, socket}
  end

  # def handle_event("paginate", %{}, socket) do
  #   if socket.assigns.page == socket.assigns.feedback_meta.total_pages do
  #     {:noreply, socket}
  #   else
  #     page = socket.assigns.page + 1

  #     tracks = list_tracks(page, socket.assigns)
  #     feedbacks_meta = track_meta(tracks)

  #     {:noreply,
  #      socket
  #      |> assign(:page, page)
  #      |> assign(:feedbacks_meta, feedbacks_meta)
  #      |> assign(:tracks, tracks.entries |> Enum.map(fn item -> item.track end))}
  #   end
  # end

  ##########################################
  # Helper functions for data loading
  ##########################################

  defp maybe_assign_feedback(socket, feedback, feedback_votes) do
    case socket.assigns.feedback.id == feedback.id do
      true -> socket |> assign(feedback: feedback, feedback_votes: feedback_votes)
      false -> socket
    end
  end

  defp subscribe_for_notifications(nil), do: nil
  defp subscribe_for_notifications([]), do: nil

  defp subscribe_for_notifications(feedbacks) when is_list(feedbacks) do
    feedbacks
    |> Enum.each(&subscribe_for_notifications(&1))
  end

  defp subscribe_for_notifications(%Feedback{id: feedback_id}) do
    Notifications.subscribe_feedback(feedback_id)
  end

  ##########################################
  # Helper functions for HEEX rendering
  ##########################################

  # Renders a badge showing online or offline status
  attr :status, :string,
    default: "blank",
    values: ~w(loading online offline blank)

  defp online_status(assigns) do
    ~H"""
    <div :if={@status != "blank"}>
      <div
        :if={@status == "loading"}
        class="text-alert-500"
        style="display: inline-flex; transform-style: preserve-3d"
      >
        <.tabler_icon name="tabler-loader-2" class="ml-1 w-6 h-6 animate-spin" />
      </div>

      <Petal.Badge.badge
        :if={@status == "online"}
        color="success"
        variant="outline"
        label="lg"
        size="lg"
      >
        <%!-- <Petal.HeroiconsV1.Outline.status_online class="w-5 h-5 mr-1 pb-[0.025rem]" /> --%>
        <LiveSvelte.svelte name="DoubleBounceSpinner" ssr={false} props={%{size: 16, duration: "2s"}} />
        <span class="pl-2">Streaming Online</span>
      </Petal.Badge.badge>

      <Petal.Badge.badge
        :if={@status == "offline"}
        color="danger"
        variant="outline"
        label="lg"
        size="lg"
      >
        <Petal.HeroiconsV1.Outline.status_offline class="w-5 h-5 mr-1 pb-[0.025rem]" />
        <span class="pl-1">Offline</span>
      </Petal.Badge.badge>
    </div>
    """
  end
end
