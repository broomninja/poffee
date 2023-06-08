defmodule PoffeeWeb.SearchBar do
  use PoffeeWeb, :html

  import PoffeeWeb.CoreComponents, only: [modal: 1, show_modal: 1]

  def search_bar(assigns) do
    ~H"""
    <div class="flex items-center md:w-full cursor-auto" id="searchbar">
      <.modal id="live-search-modal" show_x_button={false} modal_width="w-[38rem]">
        <%= live_render(@socket, PoffeeWeb.SearchBarLive, id: "live-search") %>
      </.modal>

      <div class="md:hidden">
        <.tabler_icon_button
          icon="tabler-search"
          label="search"
          bgcolor={:white}
          phx-click={show_modal("live-search-modal")}
          size={:md}
        />
      </div>

      <div class="hidden md:block md:max-w-xs md:flex-auto ">
        <button
          type="button"
          class="hidden text-gray-500 bg-white hover:ring-gray-500 ring-gray-300 h-8 w-full items-center gap-2 rounded-md pl-2 pr-3 text-sm ring-1 transition md:flex justify-between focus:[&amp;:not(:focus-visible)]:outline-none"
          phx-click={show_modal("live-search-modal")}
          id="searchbar-open-button"
        >
          <div class="flex items-center pr-8">
            <.tabler_icon name="tabler-search" class="w-4 h-4 mr-1" /> Search
          </div>
          <%!-- <kbd class="ml-auto text-3xs opacity-80">
            <kbd class="font-sans">⌘</kbd><kbd class="font-sans">K</kbd>
          </kbd> --%>
        </button>
      </div>
    </div>
    """
  end
end
