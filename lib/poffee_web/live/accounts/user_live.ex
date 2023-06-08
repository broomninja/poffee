defmodule PoffeeWeb.UserLive do
  use PoffeeWeb, :live_view

  alias Poffee.Accounts

  require Logger

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
    <% end %>
    """
  end

  @impl Phoenix.LiveView
  def handle_params(%{"username" => username}, _url, socket) do
    user = Accounts.get_user_by_username(username)
    {:noreply, assign(socket, :user_found, user)}
  end
end
