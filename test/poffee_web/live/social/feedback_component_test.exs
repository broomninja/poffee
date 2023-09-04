defmodule PoffeeWeb.FeedbackComponentTest do
  use PoffeeWeb.ConnCase, async: false

  import Poffee.AccountsFixtures
  import Poffee.SocialFixtures
  import Poffee.StreamingFixtures

  import Phoenix.LiveViewTest

  require Logger

  describe "Feedback Component" do
    setup do
      feedback_author = user_fixture()
      streamer = user_fixture()
      brand_page = brand_page_fixture(streamer)
      twitch_user = twitch_user_fixture(streamer)

      feedbacks =
        1..9
        |> Enum.map(fn num ->
          feedback_fixture(feedback_author, brand_page, %{
            title: "title #{num}",
            content: "content #{num}"
          })
        end)

      %{feedbacks: feedbacks, brand_page: brand_page, twitch_user: twitch_user}
    end

    test "create comment in single feedback", %{
      conn: conn,
      feedbacks: feedbacks,
      brand_page: brand_page,
      twitch_user: twitch_user
    } do
      password = "123456789abcd"
      user = user_fixture(%{password: password})

      brand_page_path = ~p"/u/#{twitch_user.display_name}"

      {:ok, view, _html} = live(conn, brand_page_path)

      user_login_liveview = find_live_child(view, "live-login")

      form =
        form(user_login_liveview, "#login_form",
          user: %{email: user.email, password: password, user_return_to: brand_page_path}
        )

      conn = submit_form(form, conn)
      first_feedback = List.first(feedbacks)

      assert Phoenix.Flash.get(conn.assigns.flash, :info) == "Welcome back!"
      assert redirected_to(conn) == brand_page_path

      feedback_path = ~p"/u/#{twitch_user.display_name}/#{first_feedback.id}"

      # click on the feedback title ahref
      {:ok, view, _} =
        view
        |> element("div a", first_feedback.title)
        |> render_click()
        |> follow_redirect(conn, feedback_path)

      test_comment = "dummy comment for #{first_feedback.id}"

      # no comments should be displayed yet
      refute has_element?(view, "div.bg-orange-50 span.whitespace-pre-wrap", test_comment)

      # IO.inspect("#{Poffee.Env.livesvelte_enable_ssr?()}", label: "LiveSvelte SSR")

      # simulate pushEventTo for creating a comment
      view
      |> with_target("#brand_page-#{brand_page.id}")
      |> render_click("create_comment", %{
        "content" => test_comment,
        "user_id" => user.id,
        "feedback_id" => first_feedback.id
      })

      html = render(view)
      assert html =~ "Comment created!"
      
      assert has_element?(view, "div.bg-orange-50 span.whitespace-pre-wrap", test_comment)
      # TODO: LiveSvelte SSR 
      # assert has_element?(view, "button span#feedback-votes-count", "0")

      # simulate clicking on Vote
      view
      |> with_target("#brand_page-#{brand_page.id}")
      |> render_click("vote", %{
        "user_id" => user.id,
        "feedback_id" => first_feedback.id
      })

      html = render(view)
      assert html =~ "Vote saved!"

      # element =
      #   html
      #   |> Floki.parse_document!()
      #   |> Floki.find("button span#feedback-votes-count")
      # IO.inspect("#{inspect(element)}", label: "Floki vote count")

      # make sure the new comment is still visible after voting
      assert has_element?(view, "div.bg-orange-50 span.whitespace-pre-wrap", test_comment)
      # TODO: LiveSvelte SSR 
      # assert has_element?(view, "button span#feedback-votes-count", "1")
    end
  end
end
