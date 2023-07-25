defmodule Poffee.Social.FeedbackComponent do
  use PoffeeWeb, :live_component

  alias Poffee.Utils

  require Logger

  @default_assigns %{}

  @impl Phoenix.LiveComponent
  def mount(socket) do
    {:ok, assign(socket, @default_assigns), temporary_assigns: []}
  end

  ##########################################
  # Helper functions for HEEX rendering
  ##########################################

  def get_container_id(id) do
    "feedback-#{id}"
  end

  attr :voters, :list, required: true

  defp voters_list(assigns) do
    ~H"""
    <div>
      Voters
      <div :if={Utils.is_non_empty_list?(@voters)}>
        <.voter :for={voter <- @voters} username={voter.username} creation_time={voter} />
      </div>
      <div :if={!Utils.is_non_empty_list?(@voters)}>
        None
      </div>
    </div>
    """
  end

  # Displays the voter name and time 
  attr :username, :string, required: true
  attr :creation_time, :any, required: true

  defp voter(assigns) do
    ~H"""
    <div class="flex items-center justify-start font-semibold">
      <Petal.HeroiconsV1.Solid.user class="w-5 h-5 pb-[0.025rem]" />
      <span class="pl-1"><%= @username %></span>
    </div>
    """
  end
end
