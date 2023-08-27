defmodule PoffeeWeb.FeedbackComponentTest do
  use PoffeeWeb.ConnCase, async: false

  import Poffee.AccountsFixtures
  import Poffee.SocialFixtures
  import Poffee.StreamingFixtures

  import Phoenix.LiveViewTest

  require Logger

  describe "Feedback Component" do
    setup do
      streamer = user_fixture()
      brand_page = brand_page_fixture(streamer)
      twitch_user = twitch_user_fixture(streamer)

      feedbacks =
        1..9
        |> Enum.map(fn num ->
          feedback_fixture(streamer, brand_page, %{
            title: "title #{num}",
            content: "content #{num}"
          })
        end)

      %{feedbacks: feedbacks, brand_page: brand_page, twitch_user: twitch_user}
    end

    test "create comment in single feedback", %{conn: conn, feedbacks: feedbacks, twitch_user: twitch_user} do
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

      # simulate pushEventTo when creating comment
      _html =
        view
        |> with_target("#feedback-#{first_feedback.id}")
        |> render_click("create_comment", %{
          "content" => test_comment,
          "user_id" => user.id,
          "feedback_id" => first_feedback.id
        })

      # element =
      #   html
      #   |> Floki.parse_document!()
      #   |> Floki.find("span.whitespace-pre-wrap")

      # IO.inspect("#{inspect(element)}", label: "Floki comment display")

      assert has_element?(view, "div.bg-orange-50 span.whitespace-pre-wrap", test_comment)
    end
  end
end
