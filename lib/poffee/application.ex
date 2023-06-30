defmodule Poffee.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # LiveSvelte SSR
      {NodeJS.Supervisor, [path: LiveSvelte.SSR.server_path(), pool_size: 4]},
      # Start the Telemetry supervisor
      PoffeeWeb.Telemetry,
      # Start the Ecto repository
      Poffee.Repo,
      # Start the DB Cache
      {Poffee.DBCache, []},
      # Start the PubSub system
      {Phoenix.PubSub, name: Poffee.PubSub},
      # Start Finch
      {Finch, name: Poffee.Finch},
      # Start FunWithFlags
      FunWithFlags.Supervisor,
      # Start Twitch Supervisor
      Poffee.Streaming.TwitchSupervisor,
      # Start the Endpoint (http/https)
      PoffeeWeb.Endpoint
      # Start a worker by calling: Poffee.Worker.start_link(arg)
      # {Poffee.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Poffee.Supervisor]
    result = Supervisor.start_link(children, opts)

    # Replace default Repo logging
    # Ecto.DevLogger.install(Poffee.Repo)

    result
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PoffeeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
