defmodule PoffeeWeb.SearchBarLive do
  use PoffeeWeb, :live_view

  alias Poffee.Accounts
  alias Poffee.Utils

  require Logger

  @default_assigns %{
    search_query: nil,
    search_result: nil,
    loading_search?: false
  }

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, assign(socket, @default_assigns), temporary_assigns: []}
  end

  @impl Phoenix.LiveView
  def handle_event("search_event", %{"search_query" => ""}, socket) do
    socket =
      socket
      |> assign(:search_query, nil)
      |> assign(:search_result, nil)
      |> assign(:loading_search?, false)

    {:noreply, socket}
  end

  def handle_event("search_event", %{"search_query" => search_query}, socket) do
    socket =
      socket
      |> assign(:search_query, search_query)
      |> assign(:loading_search?, true)

    # send message to self for performing the search, so user can see the loading spinner
    # while searching
    send(self(), {__MODULE__, :run_search, search_query, 1})

    {:noreply, socket}
  end

  def handle_event("goto-page", %{"page" => page}, socket) do
    send(self(), {__MODULE__, :run_search, socket.assigns.search_query, page})
    {:noreply, assign(socket, :loading_search?, true)}
  end

  @impl Phoenix.LiveView
  def handle_info({__MODULE__, :run_search, search_query, page}, socket) do
    paginated_users = Accounts.user_search(search_query, %{"page" => page})
    users = paginated_users.entries
    pagination_meta = Map.delete(paginated_users, :entries)

    socket =
      socket
      |> assign(:search_result, %{users: users})
      |> assign(:pagination_meta, pagination_meta)
      |> assign(:loading_search?, false)

    {:noreply, socket}
  end

  ##########################################
  # Helper functions for data loading
  ##########################################

  defp clear_search(js \\ %JS{}, to \\ "#search-input") do
    js
    |> JS.dispatch("js:clear_search", to: to)
    |> JS.focus(to: to)
    |> JS.push("search_event", value: %{"search_query" => ""})
  end

  ##########################################
  # Helper functions for HEEX rendering
  ##########################################
end
