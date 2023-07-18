defmodule Poffee.SocialTest do
  use Poffee.DataCase, async: true

  alias Poffee.Social
  alias Poffee.Social.BrandPage
  alias Poffee.Social.Feedback

  import Poffee.SocialFixtures
  import Poffee.AccountsFixtures

  describe "brand_pages" do
    @invalid_attrs %{title: nil}

    setup do
      %{user: user_fixture()}
    end

    test "list_brand_pages/0 returns all brand_pages", %{user: user} do
      brand_page = brand_page_fixture(user)
      assert Social.list_brand_pages() == [brand_page]
    end

    test "get_brand_page!/1 returns the brand_page with given id", %{user: user} do
      brand_page = brand_page_fixture(user)
      assert Social.get_brand_page!(brand_page.id) == brand_page
    end

    test "create_brand_page/1 with valid data data and trailing whitespace creates a brand_page",
         %{user: user} do
      valid_attrs = %{title: " some title "}

      assert {:ok, %BrandPage{} = brand_page} = Social.create_brand_page(valid_attrs, user)
      assert brand_page.title == "some title"
    end

    test "create_brand_page/1 with html tags stripped off", %{user: user} do
      html_attrs = %{
        title: " <div>some <b>title</b></div> ",
        description: "some <script>description</script> "
      }

      assert {:ok, %BrandPage{} = brand_page} = Social.create_brand_page(html_attrs, user)
      assert brand_page.title == "some title"
      assert brand_page.description == "some description"
    end

    test "create_brand_page/1 with html tags only data returns error changeset", %{user: user} do
      html_attrs = %{title: " <div> <b></b></div> ", description: " <script> </script> "}

      assert {:error, %Ecto.Changeset{}} = Social.create_brand_page(html_attrs, user)
    end

    test "create_brand_page/1 with invalid data returns error changeset", %{user: user} do
      assert {:error, %Ecto.Changeset{}} = Social.create_brand_page(@invalid_attrs, user)
    end

    test "update_brand_page/2 with valid data updates the brand_page", %{user: user} do
      brand_page = brand_page_fixture(user)
      update_attrs = %{title: "some updated title"}

      assert {:ok, %BrandPage{} = brand_page} = Social.update_brand_page(brand_page, update_attrs)
      assert brand_page.title == "some updated title"
    end

    test "update_brand_page/2 with invalid data returns error changeset", %{user: user} do
      brand_page = brand_page_fixture(user)
      assert {:error, %Ecto.Changeset{}} = Social.update_brand_page(brand_page, @invalid_attrs)
      assert brand_page == Social.get_brand_page!(brand_page.id)
    end

    test "delete_brand_page/1 deletes the brand_page", %{user: user} do
      brand_page = brand_page_fixture(user)
      assert {:ok, %BrandPage{}} = Social.delete_brand_page(brand_page)
      assert_raise Ecto.NoResultsError, fn -> Social.get_brand_page!(brand_page.id) end
    end

    test "change_brand_page/1 returns a brand_page changeset", %{user: user} do
      brand_page = brand_page_fixture(user)
      assert %Ecto.Changeset{} = Social.change_brand_page(brand_page)
    end

    test "get_brand_page_with_feedbacks_by_user/1 returns same brand_page", %{user: user} do
      brand_page = brand_page_fixture(user, %{status: :brand_page_status_public})
      assert %BrandPage{} = loaded_brand_page = Social.get_brand_page_with_feedbacks_by_user(user)
      assert loaded_brand_page.id == brand_page.id
      assert loaded_brand_page.title == brand_page.title
    end

    test "get_brand_page_with_feedbacks_by_user/1 returns nil when status is private", %{
      user: user
    } do
      _brand_page = brand_page_fixture(user, %{status: :brand_page_status_private})
      assert nil == Social.get_brand_page_with_feedbacks_by_user(user)
    end
  end

  describe "feedbacks" do
    @invalid_attrs %{content: nil, title: nil}

    setup do
      user = user_fixture()

      %{user: user, brand_page: brand_page_fixture(user)}
    end

    test "list_feedbacks/0 returns all feedbacks", %{user: user, brand_page: brand_page} do
      feedback = feedback_fixture(user, brand_page)
      assert Social.list_feedbacks() == [feedback]
    end

    test "get_feedback!/1 returns the feedback with given id", %{
      user: user,
      brand_page: brand_page
    } do
      feedback = feedback_fixture(user, brand_page)
      assert Social.get_feedback!(feedback.id) == feedback
    end

    test "create_feedback/1 with valid data and trailing whitespace creates a feedback", %{
      user: user,
      brand_page: brand_page
    } do
      valid_attrs = %{content: " some content ", title: " some title "}

      assert {:ok, %Feedback{} = feedback} = Social.create_feedback(valid_attrs, user, brand_page)
      assert feedback.content == "some content"
      assert feedback.title == "some title"
    end

    test "create_feedback/1 with html tags stripped off", %{
      user: user,
      brand_page: brand_page
    } do
      html_attrs = %{
        content: "<div>some <b>content</b></div>",
        title: "some <script>title</script>"
      }

      assert {:ok, %Feedback{} = feedback} = Social.create_feedback(html_attrs, user, brand_page)
      assert feedback.content == "some content"
      assert feedback.title == "some title"
    end

    test "create_feedback/1 with html tags only data returns error changeset", %{
      user: user,
      brand_page: brand_page
    } do
      html_attrs = %{content: " <div> <b></b></div> ", title: " <script> </script> "}

      assert {:error, %Ecto.Changeset{}} = Social.create_feedback(html_attrs, user, brand_page)
    end

    test "create_feedback/1 with invalid data returns error changeset", %{
      user: user,
      brand_page: brand_page
    } do
      assert {:error, %Ecto.Changeset{}} =
               Social.create_feedback(@invalid_attrs, user, brand_page)
    end

    test "update_feedback/2 with valid data updates the feedback", %{
      user: user,
      brand_page: brand_page
    } do
      feedback = feedback_fixture(user, brand_page)
      update_attrs = %{content: "some updated content", title: "some updated title"}

      assert {:ok, %Feedback{} = feedback} = Social.update_feedback(feedback, update_attrs)
      assert feedback.content == "some updated content"
      assert feedback.title == "some updated title"
    end

    test "update_feedback/2 with invalid data returns error changeset", %{
      user: user,
      brand_page: brand_page
    } do
      feedback = feedback_fixture(user, brand_page)
      assert {:error, %Ecto.Changeset{}} = Social.update_feedback(feedback, @invalid_attrs)
      assert feedback == Social.get_feedback!(feedback.id)
    end

    test "delete_feedback/1 deletes the feedback", %{user: user, brand_page: brand_page} do
      feedback = feedback_fixture(user, brand_page)
      assert {:ok, %Feedback{}} = Social.delete_feedback(feedback)
      assert_raise Ecto.NoResultsError, fn -> Social.get_feedback!(feedback.id) end
    end

    test "change_feedback/1 returns a feedback changeset", %{user: user, brand_page: brand_page} do
      feedback = feedback_fixture(user, brand_page)
      assert %Ecto.Changeset{} = Social.change_feedback(feedback)
    end

    test "get_user_with_brand_page_and_feedbacks/1 returns user with loaded brand_page and feedbacks",
         %{user: user, brand_page: brand_page} do
      _feedback = feedback_fixture(user, brand_page, %{title: "title 1", content: "content 1"})
      _feedback = feedback_fixture(user, brand_page, %{title: "title 2", content: "content 2"})

      _feedback =
        feedback_fixture(user, brand_page, %{
          title: "title 3",
          content: "content 3",
          status: :feedback_status_removed
        })

      loaded_user = Social.get_user_with_brand_page_and_feedbacks_by_username(user.username)
      assert loaded_user.brand_page.id == brand_page.id
      assert loaded_user.brand_page.title == brand_page.title

      loaded_user.brand_page.feedbacks
      |> Enum.each(&assert(&1.status == :feedback_status_active))

      assert length(loaded_user.brand_page.feedbacks) == 2
    end

    test "get_brand_page_with_feedbacks_by_user/1 returns user with loaded brand_page and feedbacks",
         %{user: user, brand_page: brand_page} do
      _feedback = feedback_fixture(user, brand_page, %{title: "title 1", content: "content 1"})
      _feedback = feedback_fixture(user, brand_page, %{title: "title 2", content: "content 2"})

      _feedback =
        feedback_fixture(user, brand_page, %{
          title: "title 3",
          content: "content 3",
          status: :feedback_status_removed
        })

      loaded_brand_page = Social.get_brand_page_with_feedbacks_by_user(user)
      assert loaded_brand_page.id == brand_page.id
      assert loaded_brand_page.title == brand_page.title

      loaded_brand_page.feedbacks
      |> Enum.each(&assert(&1.status == :feedback_status_active))

      assert length(loaded_brand_page.feedbacks) == 2
    end
  end

  describe "comments" do
    alias Poffee.Social.Comment

    import Poffee.SocialFixtures

    @invalid_attrs %{content: nil}

    setup do
      user = user_fixture()
      brand_page = brand_page_fixture(user)

      %{user: user, feedback: feedback_fixture(user, brand_page)}
    end

    test "list_comments/0 returns all comments", %{
      user: user,
      feedback: feedback
    } do
      comment = comment_fixture(user, feedback)
      assert Social.list_comments() == [comment]
    end

    test "get_comment!/1 returns the comment with given id", %{
      user: user,
      feedback: feedback
    } do
      comment = comment_fixture(user, feedback)
      assert Social.get_comment!(comment.id) == comment
    end

    test "create_comment/1 with valid data creates a comment", %{
      user: user,
      feedback: feedback
    } do
      valid_attrs = %{content: "some content"}

      assert {:ok, %Comment{} = comment} = Social.create_comment(valid_attrs, user, feedback)
      assert comment.content == "some content"
    end

    test "create_comment/1 with invalid data returns error changeset", %{
      user: user,
      feedback: feedback
    } do
      assert {:error, %Ecto.Changeset{}} = Social.create_comment(@invalid_attrs, user, feedback)
    end

    test "update_comment/2 with valid data updates the comment", %{
      user: user,
      feedback: feedback
    } do
      comment = comment_fixture(user, feedback)
      update_attrs = %{content: "some updated content"}

      assert {:ok, %Comment{} = comment} = Social.update_comment(comment, update_attrs)
      assert comment.content == "some updated content"
    end

    test "update_comment/2 with invalid data returns error changeset", %{
      user: user,
      feedback: feedback
    } do
      comment = comment_fixture(user, feedback)
      assert {:error, %Ecto.Changeset{}} = Social.update_comment(comment, @invalid_attrs)
      assert comment == Social.get_comment!(comment.id)
    end

    test "delete_comment/1 deletes the comment", %{
      user: user,
      feedback: feedback
    } do
      comment = comment_fixture(user, feedback)
      assert {:ok, %Comment{}} = Social.delete_comment(comment)
      assert_raise Ecto.NoResultsError, fn -> Social.get_comment!(comment.id) end
    end

    test "change_comment/1 returns a comment changeset", %{
      user: user,
      feedback: feedback
    } do
      comment = comment_fixture(user, feedback)
      assert %Ecto.Changeset{} = Social.change_comment(comment)
    end
  end

  describe "feedback_votes" do
    alias Poffee.Social.FeedbackVote

    import Poffee.SocialFixtures

    @invalid_attrs %{}

    setup do
      user = user_fixture()
      brand_page = brand_page_fixture(user)

      %{user: user, feedback: feedback_fixture(user, brand_page)}
    end

    test "get_feedback_votes_by_user/1 returns all feedback_votes", %{
      user: user,
      feedback: feedback
    } do
      {:ok, feedback_vote} = Social.vote_feedback(user, feedback)
      assert Social.get_feedback_votes_by_user(user) == [feedback_vote]
      assert Social.get_feedback_votes_by_feedback(feedback) == [feedback_vote]
    end

    test "vote_feedback/2 with duplicate data returns error changeset", %{
      user: user,
      feedback: feedback
    } do
      {:ok, feedback_vote} = Social.vote_feedback(user, feedback)
      assert {:error, %Ecto.Changeset{}} = Social.vote_feedback(user, feedback)
    end

    test "unvote_feedback/2 deletes the vote", %{
      user: user,
      feedback: feedback
    } do
      {:ok, _feedback_vote} = Social.vote_feedback(user, feedback)
      assert {1, _} = Social.unvote_feedback(user, feedback)
      assert {0, _} = Social.unvote_feedback(user, feedback)
      assert Social.get_feedback_votes_by_user(user) == []
    end
  end
end
