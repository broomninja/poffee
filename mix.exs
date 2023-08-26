defmodule Poffee.MixProject do
  use Mix.Project

  def project do
    [
      app: :poffee,
      version: version(),
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      preferred_cli_env: [
        e2e: :test,
        "test.watch": :test,
        "test.all": :test,
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      test_coverage: [tool: ExCoveralls, test_task: "test.all"],
      deps: deps(),
      releases: [
        poffee: [
          steps: [:assemble, &copy_prod_runtime_config/1]
          # validate_compile_env: false
        ]
      ]
    ]
  end

  defp version do
    # Use dummy version for dev and test
    System.get_env("VERSION", "0.0.1")
  end

  defp copy_prod_runtime_config(%Mix.Release{version_path: path} = release) do
    File.cp!(
      Path.join(["config", "config_helper.exs"]),
      Path.join([path, "config_helper.exs"])
    )

    release
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Poffee.Application, []},
      included_applications: [:fun_with_flags],
      extra_applications: [:logger, :runtime_tools, :os_mon]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support", "test/poffee"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # phoenix
      {:phoenix, "~> 1.7.2"},
      {:phoenix_ecto, "~> 4.4"},
      {:phoenix_html, "~> 3.3"},
      {:phoenix_pubsub, "~> 2.0"},
      {:bandit, "~> 1.0-pre"},

      # liveview
      {:phoenix_live_view, github: "phoenixframework/phoenix_live_view", override: true},
      # {:phoenix_live_view, "~> 0.18.18"},
      {:phoenix_live_dashboard, github: "phoenixframework/phoenix_live_dashboard"},
      # {:phoenix_live_dashboard, "~> 0.7.2"},
      # {:phoenix_live_session, "~> 0.1.3"},
      {:phoenix_live_session, github: "broomninja/phoenix_live_session"},
      {:phoenix_live_reload, "~> 1.4", only: :dev},

      # auth
      {:bcrypt_elixir, "~> 3.0"},

      # datastore
      {:ecto_enum, "~> 1.4"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:scrivener_ecto, "~> 2.7"},
      {:nebulex, "~> 2.5"},
      {:ex_audit, "~> 0.10"},

      # mail / smtp
      {:swoosh, "~> 1.3"},
      {:finch, "~> 0.13"},

      # rules / feature flag
      {:fun_with_flags, "~> 1.10.1"},
      {:opus, "~> 0.8"},
      {:let_me, "~> 1.1"},
      {:html_sanitize_ex, "~> 1.4"},

      # UI
      {:tailwind, "~> 0.2.0", runtime: Mix.env() == :dev},
      {:live_svelte, "~> 0.8.0"},
      {:petal_components, "~> 1.4.7"},

      # metrics
      {:telemetry, "~> 1.2"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:ecto_psql_extras, "~> 0.7"},

      # misc / utils
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:timex, "~> 3.7.11"},
      {:ecto_commons, "~> 0.3.3"},
      {:decorator, "~> 1.4"},
      {:slugify, "~> 1.3"},
      {:remote_ip, "~> 1.1"},

      # twitch
      {:twitch_api, github: "broomninja/twitch_api"},

      # debugging
      {:recon, "~> 2.5"},
      {:observer_cli, "~> 1.7"},
      {:load_control, github: "broomninja/load_control"},

      # dev and test deps
      {:benchee, "~> 1.0", only: :dev},
      {:dialyxir, "~> 1.3", only: :dev, runtime: false},
      {:gradient, github: "esl/gradient", only: :dev, runtime: false},
      {:typed_ecto_schema, "~> 0.4.1", runtime: false},
      {:floki, ">= 0.34.2", only: :test},
      {:excoveralls, "~> 0.16", only: :test},
      {:ex_machina, "~> 2.7", only: :test},
      {:mox, "~> 1.0", only: :test},
      {:rewire, "~> 0.9", only: :test},
      {:assertions, "~> 0.19", only: :test},
      {:live_isolated_component, "~> 0.6.5", only: :test},
      {:wallaby, "~> 0.30", only: :test, runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      # wallaby
      e2e: [
        # "esbuild default",
        "ecto.drop --quiet",
        "ecto.create --quiet",
        "ecto.migrate --quiet",
        "test --only \"e2e\""
      ],
      setup: ["deps.get", "ecto.setup", "assets.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.drop --quiet", "ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "test.all": ["test --include e2e"],
      # "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      # "assets.build": ["tailwind default", "esbuild default"],
      # "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"]
      "assets.setup": ["cmd --cd assets npm install"],
      "assets.deploy": [
        "tailwind default --minify",
        "cmd --cd assets node build.js --deploy",
        "phx.digest"
      ]
    ]
  end
end
