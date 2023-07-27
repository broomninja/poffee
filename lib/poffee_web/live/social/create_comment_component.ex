defmodule Poffee.Social.CreateCommentComponent do
  use PoffeeWeb, :live_component

  require Logger

  @default_assigns %{}

  @impl Phoenix.LiveComponent
  def mount(socket) do
    {:ok, assign(socket, @default_assigns), temporary_assigns: []}
  end

  ##########################################
  # Helper functions for HEEX rendering
  ##########################################
end
