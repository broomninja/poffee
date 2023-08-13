defmodule PoffeeWeb.ActiveStreamersLive do
  use PoffeeWeb, :live_view

  alias Poffee.Social.MostActiveStore
  alias Poffee.Social.Notifications

  require Logger

  @default_assigns %{}
  @display_limit 8

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign_most_active()
      |> maybe_subscribe_to_most_active_store()

    {:ok, assign(socket, @default_assigns), layout: false, temporary_assigns: []}
  end

  @impl Phoenix.LiveView
  def handle_info(
        {MostActiveStore, :updated_most_active, top_by_feedback_counts,
         top_by_feedback_vote_counts},
        socket
      ) do
    Logger.debug("[ActiveStreamersLive.handle_info.updated_most_active]")

    socket =
      socket
      |> assign(top_by_feedback_counts: top_by_feedback_counts |> Enum.take(@display_limit))
      |> assign(
        top_by_feedback_vote_counts: top_by_feedback_vote_counts |> Enum.take(@display_limit)
      )

    {:noreply, socket}
  end

  ##########################################
  # Helper functions for data loading
  ##########################################

  defp assign_most_active(socket) do
    socket
    |> assign(
      top_by_feedback_counts: MostActiveStore.get_most_active_by_feedbacks_count(@display_limit)
    )
    |> assign(
      top_by_feedback_vote_counts:
        MostActiveStore.get_most_active_by_feedback_votes_count(@display_limit)
    )
  end

  defp maybe_subscribe_to_most_active_store(socket) do
    if connected?(socket), do: Notifications.subscribe_most_active()

    socket
  end

  ##########################################
  # Helper functions for HEEX rendering
  ##########################################

  attr :display_name, :string, required: true
  attr :image_url, :string, required: true
  attr :value, :integer, required: true

  defp top_streamer(assigns) do
    ~H"""
    <div class="pb-1 md:pb-2">
      <.link navigate={~p"/u/#{@display_name}"}>
        <div class="flex items-center justify-start">
          <div class="w-[60px]">
            <.profile_image size={30} image_url={@image_url} name={@display_name} />
          </div>
          <div class="w-full font-semibold text-sm whitespace-nowrap pl-1">
            <%= @display_name %>
          </div>
          <div class="min-w-[20px] flex justify-center">
            <.count_display value={@value} />
          </div>
        </div>
      </.link>
    </div>
    """
  end
end
