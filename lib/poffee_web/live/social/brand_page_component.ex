defmodule Poffee.Social.BrandPageComponent do
  use PoffeeWeb, :live_component

  alias Poffee.Accounts.User
  alias Poffee.Utils

  require Logger

  @impl Phoenix.LiveComponent
  def mount(socket) do
    Logger.debug("[BrandPageComponent.mount] LC pid = #{inspect(self())}")

    {:ok, socket, temporary_assigns: []}
  end

  ##########################################
  # Helper functions for HEEX render
  ##########################################

  # show login modal when user is not logged in
  defp get_modal_name(nil), do: "live-login-modal"
  defp get_modal_name(%User{}), do: "live-create-feedback-modal"

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
        <span class="pl-2">Offline</span>
      </Petal.Badge.badge>
    </div>
    """
  end
end
