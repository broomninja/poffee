defmodule Poffee.Repo.Migrations.CreateComments do
  use Ecto.Migration

  alias Poffee.Social.Comment.CommentStatusEnum

  def change do
    CommentStatusEnum.create_type()

    create table(:comments, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :content, :text, null: false
      add :status, CommentStatusEnum.type(), null: false

      add :author_id, references(:users, on_delete: :delete_all, type: :uuid), null: false
      add :feedback_id, references(:feedbacks, on_delete: :delete_all, type: :uuid), null: false

      timestamps(type: :utc_datetime_usec)
    end

    create index(:comments, [:author_id])
    create index(:comments, [:feedback_id])
  end
end
