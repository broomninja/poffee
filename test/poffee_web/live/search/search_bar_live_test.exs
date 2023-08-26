defmodule PoffeeWeb.SearchBarLiveTest do
  use PoffeeWeb.ConnCase, async: false

  alias PoffeeWeb.SearchBarLive

  import Poffee.AccountsFixtures

  import Phoenix.LiveViewTest

  require Logger

  describe "SearchBarLive" do
    setup do
      users =
        1..15 |> Enum.map(fn n -> user_fixture(%{username: "search_bar_user_#{n}"}) end)

      %{users: users}
    end

    test "search modal with input visible", %{conn: conn} do
      {:ok, view, _} = live(conn, ~p"/u/unknown_username")

      assert has_element?(view, "button#searchbar-open-button")
      assert has_element?(view, "form#search-bar-form")
      assert has_element?(view, "input#search-input")
    end

    test "search modal username search with pagination", %{conn: conn, users: users} do
      {:ok, view, _} = live(conn, ~p"/u/unknown_username")

      # have to use live_children or live_isolated so SearchBarLive will be
      # sent the event
      # see https://github.com/phoenixframework/phoenix_live_view/issues/2483

      search_bar_liveview =
        live_children(view)
        |> Enum.find(fn v -> v.module == SearchBarLive end)

      search_bar_liveview
      |> element("#search-bar-form")
      |> render_change(%{"search_query" => "search_bar_user_"})

      # render() will send a message and synchronise with the liveview to ensure
      # any previous messages are already processed by handle_info()
      # see https://elixirforum.com/t/how-to-test-handle-info-2-in-phoenix-liveview/30070/7
      _html = render(search_bar_liveview)

      first_user = List.first(users)

      assert has_element?(search_bar_liveview, "div#search-result")
      assert has_element?(search_bar_liveview, "div.font-semibold", "Users")

      assert has_element?(search_bar_liveview, "ul li a", first_user.username)
      assert has_element?(search_bar_liveview, "ul.pc-pagination__inner li span", "1")

      assert has_element?(
               search_bar_liveview,
               "ul.pc-pagination__inner li span.pc-pagination__item",
               "1"
             )

      assert has_element?(
               search_bar_liveview,
               "ul.pc-pagination__inner li button.pc-pagination__item",
               "2"
             )
    end
  end
end
