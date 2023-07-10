defmodule Poffee.Repo.Migrations.CreateTwitchUsers do
  use Ecto.Migration

  def change do
    create table(:twitch_users, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :twitch_user_id, :string
      add :description, :text
      add :display_name, :string
      add :login, :string
      add :profile_image_url, :string
      add :user_id, references(:users, on_delete: :delete_all, type: :uuid)

      timestamps(type: :utc_datetime_usec)
    end

    create index(:twitch_users, [:user_id])
  end
end
