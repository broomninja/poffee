defmodule Poffee.Repo do
  use Ecto.Repo,
    otp_app: :poffee,
    adapter: Ecto.Adapters.Postgres

  use ExAudit.Repo

  use Scrivener, page_size: 10

  # require Logger

  # # Installs Postgres extensions
  # def installed_extensions do
  #   ["uuid-ossp", "citext"]
  # end

  # def init(_type, config) do
  #   url = Keyword.get(config, :url)
  #   Logger.info("[Repo.init] Starting Poffee.Repo with url: #{url}")
  #   {:ok, config}
  # end
end
