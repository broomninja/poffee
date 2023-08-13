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
  alias Poffee.Social.Notifications
  alias Poffee.EctoUtils

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
  @spec create_feedback(map) :: {:ok, Feedback.t()} | changeset_error
  def create_feedback(attrs \\ %{}) do
    result =
      %Feedback{}
      |> Feedback.changeset(attrs)
      |> Repo.insert()

    with {:ok, feedback} <- result do
      :ok = Notifications.broadcast_feedback(feedback)
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
    |> preload([_, _, _, fb_a, _], author: fb_a)
    |> group_by([fb, _, _, fb_a, c_a], [fb.id, fb_a.id, c_a.id])
    |> select_merge([_, v, c, _, _], %{
      votes_count: count(v.id, :distinct),
      comments_count: count(c.id, :distinct)
    })
    |> Repo.one()
  end

  @spec get_feedbacks_with_comments_count_and_voters_count_by_brand_page_id(uuid, Keywords.t()) ::
          [
            Feedback.t()
          ]
  def get_feedbacks_with_comments_count_and_voters_count_by_brand_page_id(
        brand_page_id,
        options \\ %{}
      ) do
    Feedback
    |> where([fb], fb.brand_page_id == ^brand_page_id and fb.status == :feedback_status_active)
    |> join(:left, [fb], v in assoc(fb, :voters))
    |> join(:left, [fb], c in Comment,
      on: c.feedback_id == fb.id and c.status == :comment_status_active
    )
    |> join(:left, [fb], fb_a in User, on: fb.author_id == fb_a.id, as: :authors)
    |> join(:left, [c], c_a in User, on: c.author_id == c_a.id)
    |> order_by(^parse_sort_by(options["sort_by"]))
    |> preload([_, _, _, fb_a, _], author: fb_a)
    |> group_by([fb, _, _, fb_a, c_a], [fb.id, fb_a.id, c_a.id])
    |> select_merge([_, v, c, _, _], %{
      comments_count: count(c.id, :distinct) |> selected_as(:comments_count),
      votes_count: count(v.id, :distinct) |> selected_as(:votes_count)
    })
    |> Repo.all()
  end

  defp parse_sort_by("oldest"), do: [asc: dynamic([fb], fb.inserted_at)]
  defp parse_sort_by("newest"), do: [desc: dynamic([fb], fb.inserted_at)]

  defp parse_sort_by("most_comments"),
    do: [
      desc: dynamic([fb], selected_as(:comments_count)),
      asc: dynamic([fb], fb.inserted_at)
      # asc: dynamic([authors: a], a.username)
    ]

  defp parse_sort_by("most_votes"),
    do: [
      desc: dynamic([fb], selected_as(:votes_count)),
      asc: dynamic([fb], fb.inserted_at)
      # asc: dynamic([authors: a], a.username)
    ]

  defp parse_sort_by(_), do: parse_sort_by(Poffee.Constant.feedback_default_sort_by())

  # @spec get_feedback_voters_by_feedback_id(uuid) :: list(User.t())
  # def get_feedback_voters_by_feedback_id(nil), do: []

  # def get_feedback_voters_by_feedback_id(feedback_id) do
  #   Feedback
  #   |> where([fb], fb.id == ^feedback_id and fb.status == :feedback_status_active)
  #   |> Repo.one()
  #   |> Repo.preload(:voters)
  #   |> Map.get(:voters)
  # end

  @doc """
  Loads all the votes and returns all the users who voted for this feedback.
  """
  @spec get_feedback_votes_by_feedback_id(uuid) :: list(FeedbackVote.t())
  def get_feedback_votes_by_feedback_id(nil), do: []

  def get_feedback_votes_by_feedback_id(feedback_id) do
    FeedbackVote
    |> where([fbv], fbv.feedback_id == ^feedback_id)
    |> join(:left, [fbv], fb in Feedback,
      on: fb.id == fbv.feedback_id and fb.status == :feedback_status_active
    )
    |> join(:left, [fbv], u in assoc(fbv, :user))
    |> preload([_, _, u], user: u)
    |> Repo.all()
  end

  @spec get_voted_feedbacks_by_user(%User{}) :: list(FeedbackVote.t({}))
  def get_voted_feedbacks_by_user(%User{} = user) do
    user
    |> Repo.preload(:voted_feedbacks)
    |> Map.get(:voted_feedbacks)
  end

  # @spec get_feedback_votes_by_feedback(%Feedback{}) :: list(FeedbackVote.t{})
  # def get_feedback_votes_by_feedback(%Feedback{} = feedback) do
  #   feedback
  #   |> Repo.preload(:voters)
  #   |> Map.get(:voters)
  # end

  @spec user_has_voted_feedback?(User.t(), uuid) :: boolean()
  def user_has_voted_feedback?(nil, _feedback_id), do: false

  def user_has_voted_feedback?(%User{id: user_id}, feedback_id) do
    FeedbackVote
    |> where(feedback_id: ^feedback_id)
    |> where(user_id: ^user_id)
    |> Repo.exists?()
  end

  @spec get_user_voted_feedback_ids_filtered_by(User.t(), list(uuid)) :: list(uuid)
  def get_user_voted_feedback_ids_filtered_by(nil, _list_of_feedback_id), do: []

  def get_user_voted_feedback_ids_filtered_by(%User{id: user_id}, list_of_feedback_id) do
    FeedbackVote
    |> where([fbv], fbv.feedback_id in ^list_of_feedback_id)
    |> where(user_id: ^user_id)
    |> select([fbv], fbv.feedback_id)
    |> Repo.all()
  end

  @spec vote_feedback(uuid, uuid) :: {:ok, FeedbackVote.t()} | changeset_error
  def vote_feedback(user_id, feedback_id) when is_binary(user_id) and is_binary(feedback_id) do
    attrs = %{feedback_id: feedback_id, user_id: user_id}

    result =
      %FeedbackVote{}
      |> FeedbackVote.changeset(attrs)
      |> Repo.insert()

    with {:ok, _feedback_vote} <- result do
      # TODO - run in new Task
      feedback = get_feedback_with_comments_count_and_voters_count_by_id(feedback_id)
      feedback_votes = get_feedback_votes_by_feedback_id(feedback_id)
      :ok = Notifications.broadcast_feedback_and_votes(feedback, feedback_votes)
    end

    result
  end

  @spec unvote_feedback(uuid, uuid) :: {:ok, FeedbackVote.t()} | changeset_error
  def unvote_feedback(user_id, feedback_id) when is_binary(user_id) and is_binary(feedback_id) do
    result =
      FeedbackVote
      |> Repo.load(%{
        user_id: EctoUtils.binary_to_ecto_uuid(user_id),
        feedback_id: EctoUtils.binary_to_ecto_uuid(feedback_id)
      })
      |> Repo.delete(
        stale_error_field: :feedback,
        stale_error_message: "feedback vote does not exist"
      )

    with {:ok, _feedback_vote} <- result do
      # TODO - run in new Task
      feedback = get_feedback_with_comments_count_and_voters_count_by_id(feedback_id)
      feedback_votes = get_feedback_votes_by_feedback_id(feedback_id)
      :ok = Notifications.broadcast_feedback_and_votes(feedback, feedback_votes)
    end

    result
  end
end
