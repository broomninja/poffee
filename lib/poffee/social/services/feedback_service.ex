defmodule Poffee.Services.FeedbackService do
  @moduledoc """
  Context module for Feedback
  """

  import Ecto.Query, warn: false
  alias Poffee.Repo

  alias Poffee.Accounts.User
  alias Poffee.Social.Comment
  alias Poffee.Social.Feedback
  alias Poffee.Social.FeedbackVote
  alias Poffee.Social.BrandPage
  alias Poffee.Notifications

  @type changeset_error :: {:error, Ecto.Changeset.t()}
  @type uuid :: <<_::128>>

  require Logger

  @doc """
  Returns the list of feedbacks.

  ## Examples

      iex> list_feedbacks()
      [%Feedback{}, ...]

  """
  def list_feedbacks do
    Repo.all(Feedback)
  end

  @doc """
  Gets a single feedback.

  Raises `Ecto.NoResultsError` if the Feedback does not exist.

  ## Examples

      iex> get_feedback!(123)
      %Feedback{}

      iex> get_feedback!(456)
      ** (Ecto.NoResultsError)

  """
  def get_feedback!(id), do: Repo.get!(Feedback, id)

  @doc """
  Gets a single feedback. Returns nil if does not exist.
  """
  def get_feedback(id), do: Repo.get(Feedback, id)

  @doc """
  Creates a feedback.
  """
  @spec create_feedback(map, User.t(), BrandPage.t()) :: {:ok, Feedback.t()} | changeset_error
  def create_feedback(attrs \\ %{}, %User{id: user_id}, %BrandPage{id: brand_page_id}) do
    attrs =
      attrs
      |> Map.put(:author_id, user_id)
      |> Map.put(:brand_page_id, brand_page_id)

    result =
      %Feedback{}
      |> Feedback.changeset(attrs)
      |> Repo.insert()

    with {:ok, _feedback} <- result do
      # :ok = Notifications.feedback_created(feedback)
    end

    result
  end

  @doc """
  Updates a feedback.
  """
  def update_feedback(%Feedback{} = feedback, attrs) do
    feedback
    |> Feedback.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a feedback.
  """
  def delete_feedback(%Feedback{} = feedback) do
    Repo.delete(feedback)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking feedback changes.

  ## Examples

      iex> change_feedback(feedback)
      %Ecto.Changeset{data: %Feedback{}}

  """
  def change_feedback(%Feedback{} = feedback, attrs \\ %{}) do
    Feedback.changeset(feedback, attrs)
  end

  ##########################
  # FeedbackVote
  ##########################

  @spec get_feedback_with_comments_count_and_voters_count_by_id(uuid) :: Feedback.t() | nil
  def get_feedback_with_comments_count_and_voters_count_by_id(nil), do: nil

  def get_feedback_with_comments_count_and_voters_count_by_id(feedback_id) do
    Feedback
    |> where([fb], fb.id == ^feedback_id and fb.status == :feedback_status_active)
    |> join(:left, [fb], v in assoc(fb, :voters))
    |> join(:left, [fb], c in Comment,
      on: c.feedback_id == fb.id and c.status == :comment_status_active
    )
    |> join(:left, [fb], fb_a in User, on: fb.author_id == fb_a.id)
    |> join(:left, [c], c_a in User, on: c.author_id == c_a.id)
    |> preload([_, v, _, fb_a, _], author: fb_a)
    |> group_by([fb, _, _, fb_a, c_a], [fb.id, fb_a.id, c_a.id])
    |> select_merge([_, v, c, _, _], %{
      votes_count: count(v.id, :distinct),
      comments_count: count(c.id, :distinct)
    })
    |> Repo.one()
  end

  # @spec get_feedback_with_comments_and_votes_by_id(uuid) :: Feedback.t() | nil
  # def get_feedback_with_comments_and_votes_by_id(
  #       feedback_id,
  #       sort_by \\ :inserted_at,
  #       sort_order \\ :asc,
  #       page \\ 1,
  #       limit \\ 10
  #     ) do

  @spec get_feedbacks_with_comments_count_and_voters_count_by_brand_page_id(uuid) :: [
          Feedback.t()
        ]
  def get_feedbacks_with_comments_count_and_voters_count_by_brand_page_id(brand_page_id) do
    Feedback
    |> where([fb], fb.brand_page_id == ^brand_page_id and fb.status == :feedback_status_active)
    |> join(:left, [fb], v in assoc(fb, :voters))
    |> join(:left, [fb], c in Comment,
      on: c.feedback_id == fb.id and c.status == :comment_status_active
    )
    |> join(:left, [fb], fb_a in User, on: fb.author_id == fb_a.id)
    |> join(:left, [c], c_a in User, on: c.author_id == c_a.id)
    |> order_by([fb], asc: fb.inserted_at)
    # |> Sorting.sort_query(Post, params, :posts)
    |> preload([_, v, _, fb_a, _], author: fb_a)
    |> group_by([fb, _, _, fb_a, c_a], [fb.id, fb_a.id, c_a.id])
    |> select_merge([_, v, c, _, _], %{
      votes_count: count(v.id, :distinct),
      comments_count: count(c.id, :distinct)
    })
    |> Repo.all()
  end

  @spec get_feedback_voters_by_feedback_id(uuid) :: list(User.t())
  def get_feedback_voters_by_feedback_id(nil), do: []

  def get_feedback_voters_by_feedback_id(feedback_id) do
    Feedback
    |> where([fb], fb.id == ^feedback_id and fb.status == :feedback_status_active)
    |> Repo.one()
    |> Repo.preload(:voters)
    |> Map.get(:voters)
  end

  # @spec get_feedback_votes_by_user(%User{}) :: list(%FeedbackVote{})
  # def get_feedback_votes_by_user(%User{} = user) do
  #   user
  #   |> Repo.preload(:feedback_votes)
  #   |> Map.get(:feedback_votes)
  # end

  # @spec get_feedback_votes_by_feedback(%Feedback{}) :: list(%FeedbackVote{})
  # def get_feedback_votes_by_feedback(%Feedback{} = feedback) do
  #   feedback
  #   |> Repo.preload(:voters)
  #   |> Map.get(:voters)
  # end

  def vote_feedback(user_id, feedback_id) do
    attrs = %{feedback_id: feedback_id, user_id: user_id}

    result =
      %FeedbackVote{}
      |> FeedbackVote.changeset(attrs)
      |> Repo.insert()

    with {:ok, feedback_vote} <- result do
      feedback =
        get_feedback_with_comments_count_and_voters_count_by_id(feedback_vote.feedback_id)

      :ok = Notifications.broadcast_feedback(feedback)
    end

    result
  end

  def unvote_feedback(user_id, feedback_id) do
    result =
      FeedbackVote
      |> where(feedback_id: ^feedback_id)
      |> where(user_id: ^user_id)
      |> Repo.delete_all()

    Logger.debug("[FeedbackService.unvote_feedback] result = #{inspect(result)}")

    #  case result do
    #   {1, _} -> feedback = get_feedback_with_comments_count_and_votes_count_by_id(feedback_vote.feedback_id)
    #             :ok = Notifications.broadcast_feedback(feedback)
    #   {0, _} -> nil
  end
end
