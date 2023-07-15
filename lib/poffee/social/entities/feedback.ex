defmodule Poffee.Social.Feedback do
  use Poffee.Schema
  import EctoEnum

  alias Poffee.Accounts.User
  alias Poffee.Social.BrandPage

  defenum(FeedbackStatusEnum, :feedback_status, [
    :feedback_status_active,
    :feedback_status_removed
  ])

  typed_schema "feedbacks" do
    field :title, :string
    field :content, :string
    field :status, FeedbackStatusEnum, default: :feedback_status_active

    belongs_to :user, User, foreign_key: :author_id
    belongs_to :brand_page, BrandPage

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(feedback, attrs) do
    feedback
    |> cast(attrs, [:title, :content, :status, :author_id, :brand_page_id])
    |> sanitize_field(:title)
    |> sanitize_field(:content)
    |> validate_required([:title, :content, :status, :author_id, :brand_page_id])
  end

  defimpl Jason.Encoder, for: __MODULE__ do
    @fields ~w(id title content status author_id brand_page inserted_at updated_at)a
    def encode(value, opts), do: jason_encode(value, @fields, opts)
  end
end
