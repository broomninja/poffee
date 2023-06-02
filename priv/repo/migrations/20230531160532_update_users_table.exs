defmodule Poffee.Repo.Migrations.UpdateUsersTable do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :username, :citext
      # add :first_name, :string
      # add :last_name, :string
    end

    create unique_index(:users, [:username])
  end
end
