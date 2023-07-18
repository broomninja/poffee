defmodule Poffee.Social.FeedbackVote do
  use Poffee.Schema

  alias Poffee.Accounts.User
  alias Poffee.Social.Feedback

  @primary_key false
  schema "feedback_votes" do
    belongs_to :feedback, Feedback, primary_key: true
    belongs_to :user, User, primary_key: true

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(feedback_vote, attrs) do
    feedback_vote
    |> cast(attrs, [:feedback_id, :user_id])
    |> validate_required([:feedback_id, :user_id])
    |> foreign_key_constraint(:feedback_id)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint([:feedback_id, :user_id],
      message: "already voted by user",
      name: :feedback_votes_pkey
    )
    |> IO.inspect(label: "changeset")
  end
end
