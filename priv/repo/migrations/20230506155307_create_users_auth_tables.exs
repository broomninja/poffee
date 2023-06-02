defmodule Poffee.Repo.Migrations.CreateUsersAuthTables do
  use Ecto.Migration

  alias Poffee.Accounts.User.RolesEnum

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    # CREATE TYPE public.role AS ENUM ('role_user', 'role_admin') []
    RolesEnum.create_type()

    create table(:users, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :email, :citext, null: false
      add :hashed_password, :string, null: false
      add :confirmed_at, :naive_datetime
      add :role, RolesEnum.type(), null: false
      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:users, [:email])
    # create unique_index(:users, ["(lower(email))"])

    create table(:users_tokens, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :user_id, references(:users, on_delete: :delete_all, type: :uuid), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      timestamps(type: :utc_datetime_usec, updated_at: false)
    end

    create index(:users_tokens, [:user_id])
    create unique_index(:users_tokens, [:context, :token])
  end
end
