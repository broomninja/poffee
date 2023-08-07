defmodule Poffee.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  require Logger

  @impl true
  def start(_type, _args) do
    is_server = Phoenix.Endpoint.server?(:poffee, PoffeeWeb.Endpoint)
    Logger.notice("[Application] Phoenix Endpoint server started? #{is_server}")
    children = get_children(is_server)

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

  defp prepend_if(list, condition, item) do
    if condition, do: [item | list], else: list
  end

  # Endpoint server is not started, only start Repo
  # eg we are running "mix run priv/repo/seeds.exs" 
  defp get_children(false) do
    [
      # Start the Ecto repository
      Poffee.Repo
    ]
  end

  # Endpoint server is running, start all the services as normal
  defp get_children(true) do
    children = [
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

    # optionally add LiveSvelte SSR, without this all LiveSvelte will not be able to use SSR
    children
    |> prepend_if(
      Poffee.Env.livesvelte_enable_ssr?(),
      {NodeJS.Supervisor, [path: LiveSvelte.SSR.server_path(), pool_size: 10]}
    )
  end
end
