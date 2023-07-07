defmodule Poffee.Social.BrandPageComponent do
  use PoffeeWeb, :live_component

  require Logger

  @impl Phoenix.LiveComponent
  def mount(socket) do
    Logger.debug("[BrandPageComponent.mount] LC pid = #{inspect(self())}")

    {:ok, socket, temporary_assigns: []}
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div id={"brandpage-#{@id}"}>
      <%= @streamer.username %>

      <.online_status status={@streaming_status} />

      <LiveSvelte.svelte
        name="BrandPage"
        ssr={false}
        props={
          %{
            streamer: @streamer,
            streaming_status: @streaming_status,
            current_user: @current_user
          }
        }
      />
    </div>
    """
  end
end
