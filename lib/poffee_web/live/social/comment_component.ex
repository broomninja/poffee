defmodule Poffee.Social.CommentComponent do
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
    "comment-#{id}"
  end
end
