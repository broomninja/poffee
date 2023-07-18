defmodule Poffee.Repo.Migrations.CreateFeedbackVotes do
  use Ecto.Migration

  def change do
    create table(:feedback_votes, primary_key: false) do
      add :feedback_id, references(:feedbacks, on_delete: :nothing, type: :uuid),
        primary_key: true

      add :user_id, references(:users, on_delete: :nothing, type: :uuid), primary_key: true

      timestamps(type: :utc_datetime_usec)
    end

    create index(:feedback_votes, [:user_id])
    create index(:feedback_votes, [:feedback_id])
  end
end
