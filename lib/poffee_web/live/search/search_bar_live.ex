defmodule PoffeeWeb.SearchBarLive do
  use PoffeeWeb, :live_view

  alias Poffee.Accounts

  require Logger

  @default_assigns %{
    search_result: nil,
    loading_search?: false
  }

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, assign(socket, @default_assigns), temporary_assigns: []}
  end

  @impl Phoenix.LiveView
  def handle_event("change", %{"search" => %{"query" => ""}}, socket) do
    socket = assign(socket, :search_result, nil)
    {:noreply, socket}
  end

  def handle_event("change", %{"search" => %{"query" => search_query}}, socket) do
    send(self(), {__MODULE__, :run_search, search_query})
    {:noreply, assign(socket, :loading_search?, true)}
  end

  @impl Phoenix.LiveView
  def handle_info({__MODULE__, :run_search, search_query}, socket) do
    socket =
      case Accounts.user_search(search_query) do
        {:ok, users} -> assign(socket, :search_result, %{users: users})
        _ -> socket
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
