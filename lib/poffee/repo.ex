defmodule Poffee.Repo do
  use Ecto.Repo,
    otp_app: :poffee,
    adapter: Ecto.Adapters.Postgres
end
