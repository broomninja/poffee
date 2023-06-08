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
    |> assign_new(:number, fn -> 15 end)
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

  def handle_event("set_number", %{"number" => number}, socket) do
    {:noreply, assign(socket, :number, number)}
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
    <button phx-click={JS.dispatch("set_input_value", bubbles: false)}>Click me!</button>

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
    </div>
    <div>
      <.link navigate={~p"/demolive"}>
        Demo Link <%!-- <img src={~p"/images/logo.svg"} width="36" /> --%>
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
          bgcolor={:warning}
          phx-click={show_modal("live-login-modal")}
          size={:md}
        />
      </div>
    <% end %>

    <div>
      <LiveSvelte.svelte name="Number" props={%{number: @number}} />
    </div>
    """
  end
end
