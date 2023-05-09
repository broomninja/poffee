defmodule Poffee.Repo do
  use Ecto.Repo,
    otp_app: :poffee,
    adapter: Ecto.Adapters.Postgres

  # # Installs Postgres extensions
  # def installed_extensions do
  #   ["uuid-ossp", "citext"]
  # end
end
