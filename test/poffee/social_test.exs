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

    test "create_brand_page/1 with valid data data and trailing whitespace creates a brand_page", %{user: user} do
      valid_attrs = %{title: " some title "}

      assert {:ok, %BrandPage{} = brand_page} = Social.create_brand_page(valid_attrs, user)
      assert brand_page.title == "some title"
    end

    test "create_brand_page/1 with html tags stripped off", %{user: user} do
      html_attrs = %{title: " <div>some <b>title</b></div> ", description: "some <script>description</script> "}

      assert {:ok, %BrandPage{} = brand_page} = Social.create_brand_page(html_attrs, user)
      assert brand_page.title == "some title"
      assert brand_page.description == "some description"
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
      html_attrs = %{content: "<div>some <b>content</b></div>", title: "some <script>title</script>"}

      assert {:ok, %Feedback{} = feedback} = Social.create_feedback(html_attrs, user, brand_page)
      assert feedback.content == "some content"
      assert feedback.title == "some title"
    end

    test "create_feedback/1 with sc data returns error changeset", %{
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

      loaded_user = Social.get_user_with_brand_page_and_feedbacks(user.id)
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
end
