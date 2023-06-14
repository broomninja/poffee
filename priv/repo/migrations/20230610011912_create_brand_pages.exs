defmodule Poffee.Repo.Migrations.CreateBrandPages do
  use Ecto.Migration

  alias Poffee.Social.BrandPage.BrandPageStatusEnum

  def change do
    BrandPageStatusEnum.create_type()

    create table(:brand_pages, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :title, :string, null: false
      add :description, :text
      add :status, BrandPageStatusEnum.type(), null: false

      add :owner_id, references(:users, on_delete: :delete_all, type: :uuid), null: false

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:brand_pages, [:owner_id])
  end
end
