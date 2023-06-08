defmodule PoffeeWeb.SearchBarLive do
  use PoffeeWeb, :live_view

  alias Poffee.Accounts

  require Logger

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:search_result, nil)
      |> assign(:loading_search?, false)

    {:ok, socket, layout: false}
  end

  @impl Phoenix.LiveView
  def handle_event("change", %{"search" => %{"query" => ""}}, socket) do
    socket = assign(socket, :search_result, nil)
    {:noreply, socket}
  end

  def handle_event("change", %{"search" => %{"query" => search_query}}, socket) do
    send(self(), {:run_search, search_query})
    {:noreply, assign(socket, :loading_search?, true)}
  end

  @impl Phoenix.LiveView
  def handle_info({:run_search, search_query}, socket) do
    socket =
      with {:ok, users} <- Accounts.user_search(search_query) do
        assign(socket, :search_result, %{users: users})
      end

    {:noreply, assign(socket, :loading_search?, false)}
  end

  defp clear_search(js \\ %JS{}, to \\ "#search-input") do
    js
    |> JS.dispatch("js:clear_search", to: to)
    |> JS.focus(to: to)
    |> JS.push("change", value: %{"search" => %{"query" => ""}})
  end
end
