defmodule Poffee.Social do
  @moduledoc """
  The Social context.
  """
  use Nebulex.Caching

  import Ecto.Query, warn: false

  alias Poffee.{Repo, Utils, DBCache}

  alias Poffee.Accounts.User
  alias Poffee.Social.BrandPage
  alias Poffee.Social.Feedback
  alias Poffee.Services.BrandPageService
  alias Poffee.Services.FeedbackService

  @ttl :timer.minutes(10)

  @decorate cacheable(cache: DBCache, opts: [ttl: @ttl], match: &Utils.can_be_cached?/1)
  @spec get_user_with_brand_page_and_feedbacks(User.t()) :: User.t()
  def get_user_with_brand_page_and_feedbacks(%User{} = user) do
    user
    |> Repo.preload(brand_page: :feedbacks)
  end

  @decorate cacheable(cache: DBCache, opts: [ttl: @ttl], match: &Utils.can_be_cached?/1)
  @spec get_brand_page_with_feedbacks_by_user(User.t()) :: BrandPage.t()
  def get_brand_page_with_feedbacks_by_user(%User{} = user) do
    BrandPage
    |> where([bp], bp.owner_id == ^user.id)
    |> join(:inner, [bp], fb in Feedback,
      on: fb.brand_page_id == bp.id and fb.status == :feedback_status_active
    )
    |> preload([bp, fb], feedbacks: fb)
    |> Repo.one()
  end

  @decorate cacheable(cache: DBCache, opts: [ttl: @ttl], match: &Utils.can_be_cached?/1)
  @spec get_feedbacks_by_user(User.t()) :: [Feedback.t()]
  def get_feedbacks_by_user(%User{} = user) do
    user
    |> Ecto.assoc(:feedbacks)
    |> Repo.all()
  end

  @decorate cacheable(cache: DBCache, opts: [ttl: @ttl], match: &Utils.can_be_cached?/1)
  @spec get_feedbacks_by_brand_page(BrandPage.t()) :: [Feedback.t()]
  def get_feedbacks_by_brand_page(%BrandPage{} = brand_page) do
    brand_page
    |> Ecto.assoc(:feedbacks)
    |> Repo.all()
  end

  @decorate cacheable(cache: DBCache, opts: [ttl: @ttl], match: &Utils.can_be_cached?/1)
  defdelegate list_brand_pages, to: BrandPageService
  defdelegate get_brand_page!(id), to: BrandPageService
  defdelegate create_brand_page(attrs, user), to: BrandPageService
  defdelegate update_brand_page(brand_page, attrs), to: BrandPageService
  defdelegate delete_brand_page(brand_page), to: BrandPageService
  defdelegate change_brand_page(brand_page, attrs), to: BrandPageService

  @decorate cacheable(cache: DBCache, opts: [ttl: @ttl], match: &Utils.can_be_cached?/1)
  defdelegate list_feedbacks, to: FeedbackService
  defdelegate get_feedback!(id), to: FeedbackService
  defdelegate create_feedback(attrs, user, brand_page), to: FeedbackService
  defdelegate update_feedback(feedback, attrs), to: FeedbackService
  defdelegate delete_feedback(feedback), to: FeedbackService
  defdelegate change_feedback(feedback, attrs), to: FeedbackService
end
