defmodule PoffeeWeb.SearchBar do
  use PoffeeWeb, :html

  import PoffeeWeb.CoreComponents, only: [show_modal: 1, hide_modal: 1]

  def search_bar(assigns) do
    ~H"""
    <div class="flex items-center lg:w-full cursor-auto" id="searchbar">
      <div class="lg:hidden">
        <.tabler_icon_button
          icon="tabler-search"
          label="search"
          bgcolor={:white}
          phx-click={show_modal("live-login-modal")}
          size={:md}
        />
      </div>

      <div class="hidden lg:block lg:max-w-xs lg:flex-auto ">
        <button
          type="button"
          class="hidden text-gray-500 bg-white hover:ring-gray-500 ring-gray-300 h-8 w-full items-center gap-2 rounded-md pl-2 pr-3 text-sm ring-1 transition lg:flex justify-between focus:[&amp;:not(:focus-visible)]:outline-none"
          phx-click={show_modal("live-login-modal")}
          id="searchbar-open-button"
        >
          <div class="flex items-center pr-2">
            <.tabler_icon name="tabler-search" class="w-4 h-4 mr-1" /> Search
          </div>
          <kbd class="ml-auto text-3xs opacity-80">
            <kbd class="font-sans">⌘</kbd><kbd class="font-sans">K</kbd>
          </kbd>
        </button>
      </div>
    </div>
    <%!-- <.modal id="live-search-modal" on_cancel={hide_modal("live-search-modal")}>
      <%= live_render(@socket, PoffeeWeb.SearchBarLive, id: "live-search") %>
    </.modal> --%>
    """
  end
end
