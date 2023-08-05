defmodule Poffee.Social.BrandPage do
  use Poffee.Schema
  import EctoEnum

  alias Poffee.Accounts.User
  alias Poffee.Social.Feedback

  defenum(BrandPageStatusEnum, :brand_page_status, [
    :brand_page_status_public,
    :brand_page_status_private
  ])

  typed_schema "brand_pages" do
    # field :slug
    field :title, :string
    field :description, :string
    field :status, BrandPageStatusEnum, default: :brand_page_status_public

    belongs_to :owner, User, foreign_key: :owner_id
    # has_many :active_feedbacks, Feedback, where: [status: :feedback_status_active]
    # we will perform filtering on context level instead
    has_many :feedbacks, Feedback
    # has_many :followers, User, through 

    # number of feedbacks this brand_page has
    field :feedbacks_count, :integer, default: 0, virtual: true
    # sum of all feedback votes under this brand_page
    field :total_feedback_votes_count, :integer, default: 0, virtual: true

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(brand_page, attrs) do
    brand_page
    |> cast(attrs, [:title, :description, :status, :owner_id])
    |> sanitize_field(:title)
    |> sanitize_field(:description)
    |> validate_required([:title, :status, :owner_id])
    |> unique_constraint(:owner_id)
  end

  defimpl Jason.Encoder, for: __MODULE__ do
    @fields ~w(id title description status user feedbacks inserted_at updated_at)a
    def encode(value, opts), do: jason_encode(value, @fields, opts)
  end
end
