defmodule PoffeeWeb.BrandPageLiveTest do
  use PoffeeWeb.ConnCase, async: false

  import Poffee.AccountsFixtures
  import Poffee.SocialFixtures
  import Poffee.StreamingFixtures

  import Phoenix.LiveViewTest

  describe "BrandPageLive" do
    setup do
      Poffee.Seeds.run()

      user = user_fixture()
      brand_page = brand_page_fixture(user)
      twitch_user = twitch_user_fixture(user)

      feedbacks =
        1..9
        |> Enum.map(fn num ->
          feedback =
            feedback_fixture(user, brand_page, %{title: "title #{num}", content: "content #{num}"})

          comments =
            1..9
            |> Enum.map(fn num ->
              comment_fixture(user, feedback, %{content: "dummy content #{num}"})
            end)

          %{feedback: feedback, comments: comments}
        end)

      %{socket: %Phoenix.LiveView.Socket{}, feedbacks: feedbacks, twitch_user: twitch_user}
    end

    test "username does not exist", %{conn: conn} do
      {:ok, view, _} = live(conn, ~p"/u/unknown_username")

      assert has_element?(view, ".pc-card__heading", "No user found")
    end

    test "username bob", %{conn: conn} do
      {:ok, view, _} = live(conn, ~p"/u/bob1")

      assert has_element?(view, ".pc-card__heading", "bob1")
    end

    test "brand page streamer", %{conn: conn, twitch_user: twitch_user} do
      {:ok, view, _html} = live(conn, ~p"/u/#{twitch_user.display_name}")

      assert has_element?(view, "a", twitch_user.display_name)
      assert has_element?(view, "img[src*=#{twitch_user.profile_image_url}]")
    end

    test "top ranked", %{conn: conn, twitch_user: twitch_user} do
      {:ok, _view, html} = live(conn, ~p"/u/unknown_username")

      assert html =~ "Most Feedbacks"
      assert html =~ twitch_user.display_name
      assert html =~ "Most Total Votes"
    end

    test "sorting and pagination for feedbacks", %{conn: conn, twitch_user: twitch_user} do
      user_path = ~p"/u/#{twitch_user.display_name}"
      # user_path = Routes.brand_page_path(conn, :show_feedbacks, twitch_user.display_name)
      {:ok, view, _} = live(conn, user_path)
      new_sort_by = "most_votes"

      {:ok, view, _} =
        view
        |> element("#sort_by_form")
        |> render_change(%{"sort_by_form" => %{"sort_by" => new_sort_by}})
        |> follow_redirect(conn, ~p"/u/#{twitch_user.display_name}?sort_by=#{new_sort_by}")

      page_num = "2"

      {:ok, view, _} =
        view
        |> element("li a.pc-pagination__item--is-not-current", page_num)
        |> render_click()
        |> follow_redirect(
          conn,
          ~p"/u/#{twitch_user.display_name}?page=#{page_num}&sort_by=#{new_sort_by}"
        )

      new_sort_by = "newest"

      view
      |> element("#sort_by_form")
      |> render_change(%{"sort_by_form" => %{"sort_by" => new_sort_by}})

      {new_path, _flash} = assert_redirect(view)
      assert new_path == ~p"/u/#{twitch_user.display_name}?sort_by=#{new_sort_by}"
    end

    test "sorting and pagination for comments", %{
      conn: conn,
      feedbacks: feedbacks,
      twitch_user: twitch_user
    } do
      user_path = ~p"/u/#{twitch_user.display_name}"
      {:ok, view, _} = live(conn, user_path)

      first_feedback_sort_by_oldest = List.first(feedbacks).feedback

      {:ok, view, _} =
        view
        |> element("a", first_feedback_sort_by_oldest.title)
        |> render_click()
        |> follow_redirect(
          conn,
          ~p"/u/#{twitch_user.display_name}/#{first_feedback_sort_by_oldest.id}"
        )

      page_num = "3"

      {:ok, view, _} =
        view
        |> element("li a.pc-pagination__item--is-not-current", page_num)
        |> render_click()
        |> follow_redirect(
          conn,
          ~p"/u/#{twitch_user.display_name}/#{first_feedback_sort_by_oldest.id}?page=#{page_num}"
        )

      new_sort_by = "newest"

      view
      |> element("#sort_by_form")
      |> render_change(%{"sort_by_form" => %{"sort_by" => new_sort_by}})

      {new_path, _flash} = assert_redirect(view)

      assert new_path ==
               ~p"/u/#{twitch_user.display_name}/#{first_feedback_sort_by_oldest.id}?sort_by=#{new_sort_by}"
    end
  end
end
