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

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <%= if is_nil(@user_found) do %>
      <div>
        <PetalCard.card>
          <PetalCard.card_content
            category="User Display"
            category_color_class="pc-card__category--secondary"
            class="max-w-sm whitespace-nowrap"
            heading="No user found"
          >
          </PetalCard.card_content>
        </PetalCard.card>
      </div>
    <% else %>
      <%= if is_nil(@user_found.brand_page) do %>
        <div>
          <PetalCard.card>
            <PetalCard.card_content
              category="User Display"
              category_color_class="pc-card__category--secondary"
              class="max-w-sm whitespace-nowrap"
              heading={@user_found.username}
            >
              User ID: <%= @user_found.id %>
            </PetalCard.card_content>
          </PetalCard.card>
        </div>
      <% else %>
        <div><%= @user_found.username %></div>
        <div><%= @user_found.brand_page.title %></div>
        <div><%= @user_found.brand_page.description %></div>
      <% end %>
    <% end %>
    """
  end
end
