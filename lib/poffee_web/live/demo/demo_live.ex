defmodule PoffeeWeb.DemoLive do
  use PoffeeWeb, :live_view

  require Logger

  @impl Phoenix.LiveView
  def mount(_params, session, socket) do
    socket =
      socket
      # |> PhoenixLiveSession.maybe_subscribe(session)
      |> put_session_assigns(session)

    Logger.debug("[mount] current url = #{inspect(socket.assigns)}")

    {:ok, socket}
  end

  defp put_session_assigns(socket, session) do
    assign_new(socket, :current_user, fn -> nil end)
    |> assign_new(:somevalue, fn -> nil end)
    |> assign(:selected_fruit, Map.get(session, "selected_fruit"))
  end

  @impl Phoenix.LiveView
  def handle_event("validate", _changes, socket) do
    {:noreply, socket}
  end

  def handle_event("select-fruit", %{"fruit" => fruit}, socket) do
    Logger.debug("[handle_event(\"select-fruit\"...]")
    PhoenixLiveSession.put_session(socket, "selected_fruit", fruit)
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_info({:live_session_updated, session}, socket) do
    Logger.debug("[handle_info({:live_session_updated...}]")
    {:noreply, put_session_assigns(socket, session)}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <%!-- <.form for={:form} action={~p"/submit"} phx-change="validate">
      <button type="submit">Submit</button>
    </.form> --%>
    <a href="/">Demo Live</a>
    <a href="/">
      <img src={~p"/images/logo.svg"} width="36" />
    </a>
    <div class="" style="display: inline-flex; transform-style: preserve-3d">
      Hero: <.icon name="hero-arrow-top-right-on-square-solid" class="h-6 w-6 animate-spin " />
    </div>

    <span class="" style="display: inline-flex; transform-style: preserve-3d">
      Tabler: <.tabler_icon name="tabler-refresh" class="ml-1 w-8 h-8 animate-spin " />
    </span>

    <span class="" style="display: inline-flex; transform-style: preserve-3d">
      Tabler: <.tabler_icon name="tabler-abc" class="ml-1 w-10 h-10 animate-spin" />
    </span>
    <div>user_return_to = <%= assigns[:user_return_to] %></div>
    <div>current_uri = <%= assigns[:current_uri] %></div>
    <div>socket = <%= # {inspect(@socket)} %></div>
    <div>
      <.link navigate={~p"/protected"}>
        Protected Link
      </.link>
      <.link navigate={~p"/demolive"}>
        Brand <%!-- <img src={~p"/images/logo.svg"} width="36" /> --%>
      </.link>
    </div>

    <div>
      Fruit = <%= @selected_fruit %>
      <p
        phx-click="select-fruit"
        phx-value-fruit="apple"
        class="font-bold hover:cursor-pointer hover:text-blue-500"
      >
        Apple
      </p>
      <p
        phx-click="select-fruit"
        phx-value-fruit="banana"
        class="font-bold hover:cursor-pointer hover:text-blue-500"
      >
        Banana
      </p>
      <p
        phx-click="select-fruit"
        phx-value-fruit="orange"
        class="font-bold hover:cursor-pointer hover:text-blue-500"
      >
        Orange
      </p>
    </div>
    <%= if @current_user do %>
      Welcome <%= @current_user.email %>
    <% else %>
      <div>
        Please log in
      </div>
      <div class="mt-4 flex items-end justify-between">
        <.tabler_icon_button
          icon="tabler-trash-x"
          label="Login"
          color={:warning}
          phx-click={show_modal("login-modal")}
          size={:md}
        />
      </div>

      <.modal id="login-modal" on_cancel={hide_modal("login-modal")}>
        <%= live_render(@socket, PoffeeWeb.UserLoginLive, id: "login", session: %{"current_uri" => assigns[:current_uri]}) %>
        
      </.modal>
    <% end %>
    """
  end
end
