defmodule Poffee.Repo do
  use AshPostgres.Repo,
    otp_app: :poffee,
    adapter: Ecto.Adapters.Postgres

  # Installs Postgres extensions that ash commonly uses
  def installed_extensions do
    ["uuid-ossp", "citext"]
  end
end
