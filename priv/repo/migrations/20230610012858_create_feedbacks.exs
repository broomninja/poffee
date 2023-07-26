defmodule Poffee.Repo.Migrations.CreateFeedbacks do
  use Ecto.Migration

  alias Poffee.Social.Feedback.FeedbackStatusEnum

  def change do
    FeedbackStatusEnum.create_type()

    create table(:feedbacks, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :title, :string, null: false
      add :content, :text, null: false
      add :status, FeedbackStatusEnum.type(), null: false

      add :author_id, references(:users, on_delete: :delete_all, type: :uuid), null: false

      add :brand_page_id, references(:brand_pages, on_delete: :delete_all, type: :uuid),
        null: false

      timestamps(type: :utc_datetime_usec)
    end

    create index(:feedbacks, [:author_id])
    create index(:feedbacks, [:brand_page_id])
  end
end
