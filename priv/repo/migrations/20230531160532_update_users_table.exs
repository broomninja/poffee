defmodule Poffee.Repo.Migrations.UpdateUsersTable do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :username, :citext
      # add :first_name, :string
      # add :last_name, :string
    end

    # execute "CREATE EXTENSION IF NOT EXISTS pg_trgm;"

    # execute """
    #   CREATE INDEX users_username_gin_trgm_idx 
    #     ON users 
    #     USING gin (username gin_trgm_ops);
    # """

    create unique_index(:users, [:username])
  end
end
