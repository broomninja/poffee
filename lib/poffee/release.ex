defmodule Poffee.Release do
  @moduledoc """
  Houses tasks that need to be executed in the released application (because mix is not present in releases).
  """
  @app :poffee

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  def repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
    # ssl required when connecting to ssl DB
    {:ok, _} = Application.ensure_all_started(:ssl)
  end
end
