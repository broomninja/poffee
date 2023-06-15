defmodule Poffee.Social.BrandPage do
  use Poffee.Schema
  import EctoEnum

  alias Poffee.Accounts.User
  alias Poffee.Social.Feedback
  alias Poffee.Utils

  defenum(BrandPageStatusEnum, :brand_page_status, [
    :brand_page_status_public,
    :brand_page_status_private
  ])

  typed_schema "brand_pages" do
    # field :slug
    field :title, :string
    field :description, :string
    field :status, BrandPageStatusEnum, default: :brand_page_status_public

    belongs_to :user, User, foreign_key: :owner_id
    # has_many :feedbacks, Feedback, where: [status: :feedback_status_active]
    # we will perform filtering on context level instead
    has_many :feedbacks, Feedback
    # has_many :followers, User, through 

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(brand_page, attrs) do
    brand_page
    |> cast(attrs, [:title, :description, :status, :owner_id])
    |> Utils.sanitize_field(:title)
    |> Utils.sanitize_field(:description)
    |> validate_required([:title, :status, :owner_id])
    |> unique_constraint(:owner_id)
  end
end
