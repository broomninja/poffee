defmodule PoffeeWeb.SearchBarLive do
  use PoffeeWeb, :live_view

  alias Poffee.Accounts

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    socket = assign(socket, places: [])
    {:ok, socket, layout: false}
  end

  @impl Phoenix.LiveView
  def handle_event("change", %{"search" => %{"query" => ""}}, socket) do
    socket = assign(socket, :places, [])
    {:noreply, socket}
  end

  def handle_event("change", %{"search" => %{"query" => search_query}}, socket) do
    users = Accounts.user_search(search_query)
    socket = assign(socket, :users, users)

    {:noreply, socket}
  end

  defp open_search_modal(js \\ %JS{}) do
    js
    |> JS.show(
      to: "#searchbox_container",
      transition:
        {"transition ease-out duration-200", "opacity-0 scale-95", "opacity-100 scale-100"}
    )
    |> JS.show(
      to: "#searchbar-dialog",
      transition: {"transition ease-in duration-100", "opacity-0", "opacity-100"}
    )
    |> JS.focus(to: "#search-input")
  end

  defp hide_search_modal(js \\ %JS{}) do
    js
    |> JS.hide(
      to: "#searchbar-searchbox_container",
      transition:
        {"transition ease-in duration-100", "opacity-100 scale-100", "opacity-0 scale-95"}
    )
    |> JS.hide(
      to: "#searchbar-dialog",
      transition: {"transition ease-in duration-100", "opacity-100", "opacity-0"}
    )
  end
end
