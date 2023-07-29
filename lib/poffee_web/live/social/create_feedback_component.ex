defmodule Poffee.Social.CreateFeedbackComponent do
  use PoffeeWeb, :live_component

  require Logger

  @default_assigns %{}

  @impl Phoenix.LiveComponent
  def mount(socket) do
    {:ok, assign(socket, @default_assigns), temporary_assigns: []}
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm pt-10 pb-14">
      <.header class="text-center">
        Create a feedback for <%= @streamer.display_name %>
      </.header>
    </div>
    """
  end

  ##########################################
  # Helper functions for HEEX rendering
  ##########################################
end
