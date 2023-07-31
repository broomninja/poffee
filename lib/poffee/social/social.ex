defmodule Poffee.Social do
  @moduledoc """
  The Social context.
  """
  use Nebulex.Caching

  import Ecto.Query, warn: false

  # alias EctoJuno.Query.Sorting
  alias Poffee.{Repo, Utils, DBCache}
  alias Poffee.Accounts.User
  alias Poffee.Social.BrandPage
  alias Poffee.Services.BrandPageService
  alias Poffee.Services.FeedbackService
  alias Poffee.Services.CommentService

  @ttl :timer.minutes(10)

  @type uuid :: <<_::128>>

  @spec get_brand_page_by_user(User.t()) :: BrandPage.t()
  def get_brand_page_by_user(%User{} = user) do
    user
    |> Ecto.assoc(:brand_page)
    |> Repo.one()
  end

  @decorate cacheable(cache: DBCache, opts: [ttl: @ttl], match: &Utils.can_be_cached?/1)
  @spec get_user_with_brand_page_by_username(String.t()) :: User.t()
  def get_user_with_brand_page_by_username(username) when is_binary(username) do
    User
    |> where([u], u.username == ^username)
    |> join(:left, [u], bp in BrandPage,
      on: bp.owner_id == u.id and bp.status == :brand_page_status_public
    )
    |> preload([_, bp], brand_page: bp)
    |> Repo.one()
  end

  # @decorate cacheable(cache: DBCache, opts: [ttl: @ttl], match: &Utils.can_be_cached?/1)
  # @spec get_user_with_brand_page_and_feedbacks_by_username(String.t()) :: User.t()
  # def get_user_with_brand_page_and_feedbacks_by_username(username) when is_binary(username) do
  #   User
  #   |> where([u], u.username == ^username)
  #   |> join(:left, [u], bp in BrandPage,
  #     on: bp.owner_id == u.id and bp.status == :brand_page_status_public
  #   )
  #   |> join(:left, [_, bp], fb in Feedback,
  #     on: fb.brand_page_id == bp.id and fb.status == :feedback_status_active
  #   )
  #   |> preload([_, bp, fb], brand_page: {bp, feedbacks: fb})
  #   |> Repo.one()
  # end

  # @decorate cacheable(cache: DBCache, opts: [ttl: @ttl], match: &Utils.can_be_cached?/1)
  # @spec get_brand_page_with_feedbacks_by_user(User.t()) :: BrandPage.t()
  # def get_brand_page_with_feedbacks_by_user(%User{} = user) do
  #   BrandPage
  #   |> where([bp], bp.owner_id == ^user.id and bp.status == :brand_page_status_public)
  #   |> join(:left, [bp], fb in Feedback,
  #     on: fb.brand_page_id == bp.id and fb.status == :feedback_status_active
  #   )
  #   |> preload([bp, fb], feedbacks: fb)
  #   |> Repo.one()
  # end

  # @decorate cacheable(cache: DBCache, opts: [ttl: @ttl], match: &Utils.can_be_cached?/1)
  # @spec get_feedbacks_by_user(User.t()) :: [Feedback.t()]
  # def get_feedbacks_by_user(%User{} = user) do
  #   user
  #   |> Ecto.assoc(:feedbacks)
  #   |> Repo.all()
  # end

  # @decorate cacheable(cache: DBCache, opts: [ttl: @ttl], match: &Utils.can_be_cached?/1)
  # @spec get_feedbacks_by_brand_page(BrandPage.t()) :: [Feedback.t()]
  # def get_feedbacks_by_brand_page(%BrandPage{} = brand_page) do
  #   brand_page
  #   |> Ecto.assoc(:feedbacks)
  #   |> Repo.all()
  # end

  ###########################
  # FeedbackVote
  ###########################

  ###########################
  # BrandPage
  ###########################
  # @decorate cacheable(cache: DBCache, opts: [ttl: @ttl], match: &Utils.can_be_cached?/1)
  defdelegate list_brand_pages, to: BrandPageService
  defdelegate get_brand_page!(id), to: BrandPageService
  defdelegate create_brand_page(attrs \\ %{}, user), to: BrandPageService
  defdelegate update_brand_page(brand_page, attrs \\ %{}), to: BrandPageService
  defdelegate delete_brand_page(brand_page), to: BrandPageService
  defdelegate change_brand_page(brand_page, attrs \\ %{}), to: BrandPageService

  ###########################
  # Feedback
  ###########################
  # @decorate cacheable(cache: DBCache, opts: [ttl: @ttl], match: &Utils.can_be_cached?/1)
  defdelegate list_feedbacks, to: FeedbackService
  defdelegate get_feedback(id), to: FeedbackService
  defdelegate get_feedback!(id), to: FeedbackService

  defdelegate get_feedback_with_comments_count_and_voters_count_by_id(feedback_id),
    to: FeedbackService

  defdelegate get_feedbacks_with_comments_count_and_voters_count_by_brand_page_id(brand_page_id),
    to: FeedbackService

  defdelegate get_feedback_votes_by_feedback_id(feedback_id), to: FeedbackService
  defdelegate create_feedback(attrs \\ %{}), to: FeedbackService
  defdelegate update_feedback(feedback, attrs \\ %{}), to: FeedbackService
  defdelegate delete_feedback(feedback), to: FeedbackService
  defdelegate change_feedback(feedback, attrs \\ %{}), to: FeedbackService
  defdelegate user_has_voted_feedback?(user, feedback_id), to: FeedbackService
  defdelegate vote_feedback(user_id, feedback_id), to: FeedbackService
  defdelegate unvote_feedback(user_id, feedback_id), to: FeedbackService

  defdelegate get_user_voted_feedback_ids_filtered_by(user, list_of_feedback_id),
    to: FeedbackService

  ###########################
  # Comment
  ###########################
  defdelegate list_comments, to: CommentService
  defdelegate get_comment!(id), to: CommentService
  defdelegate get_comments_by_feedback_id(feedback_id), to: CommentService
  defdelegate create_comment(attrs \\ %{}, user_id, feedback_id), to: CommentService
  defdelegate update_comment(feedback, attrs \\ %{}), to: CommentService
  defdelegate delete_comment(feedback), to: CommentService
  defdelegate change_comment(feedback, attrs \\ %{}), to: CommentService
end
