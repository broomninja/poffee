defmodule PoffeeWeb.UserLive do
  use PoffeeWeb, :live_view

  alias Poffee.Accounts.User
  alias Poffee.Social
  alias Poffee.Social.BrandPage

  require Logger

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    # socket =
    #   socket
    #   |> PhoenixLiveSession.maybe_subscribe(session)

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_params(%{"username" => username}, _url, socket) do
    socket =
      case Social.get_user_with_brand_page_and_feedbacks_by_username(username) do
        nil ->
          socket
          |> assign(:user_found, nil)
          |> assign(:page_title, username)

        %User{} = user ->
          socket
          |> assign(:user_found, user)
          |> assign_page_title(user.brand_page, username)
      end

    {:noreply, socket}
  end

  defp assign_page_title(socket, nil, username) do
    assign(socket, :page_title, username)
  end

  defp assign_page_title(socket, %BrandPage{} = brand_page, _username) do
    assign(socket, :page_title, brand_page.title)
  end
end
