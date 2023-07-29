defmodule Poffee.Social.CreateCommentComponent do
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
      Create Comment
    </div>
    """
  end

  ##########################################
  # Helper functions for HEEX rendering
  ##########################################
end
