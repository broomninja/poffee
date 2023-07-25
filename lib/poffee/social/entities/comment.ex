defmodule Poffee.Social.Comment do
  use Poffee.Schema
  import EctoEnum

  alias Poffee.Accounts.User
  alias Poffee.Social.Feedback

  defenum(CommentStatusEnum, :comment_status, [
    :comment_status_active,
    :comment_status_removed
  ])

  typed_schema "comments" do
    field :content, :string
    field :status, CommentStatusEnum, default: :comment_status_active

    belongs_to :author, User, foreign_key: :author_id
    belongs_to :feedback, Feedback, foreign_key: :feedback_id

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:content, :status, :author_id, :feedback_id])
    |> sanitize_field(:content)
    |> validate_required([:content, :status, :author_id, :feedback_id])
  end

  defimpl Jason.Encoder, for: __MODULE__ do
    @fields ~w(id content status author feedback inserted_at updated_at)a
    def encode(value, opts), do: jason_encode(value, @fields, opts)
  end
end
