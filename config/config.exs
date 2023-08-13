# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

####################################
# Repo
####################################
config :poffee, ecto_repos: [Poffee.Repo]

query_args = ["SET pg_trgm.similarity_threshold = 0.4", []]
# "SET random_page_cost = 1.1",
config :poffee, Poffee.Repo, after_connect: {Postgrex, :query!, query_args}

config :poffee, Poffee.Repo, migration_primary_key: [type: :uuid]

####################################
# Web Endpoint
####################################
config :poffee, PoffeeWeb.Endpoint,
  adapter: Bandit.PhoenixAdapter,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: PoffeeWeb.ErrorHTML, json: PoffeeWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Poffee.PubSub,
  live_view: [
    signing_salt: "eII60wnm",
    # the idle time in ms, before compressing its own memory and state
    # default is 15secs
    hibernate_after: 15000
  ]

####################################
# Mailer / SMTP
####################################
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :poffee, Poffee.Mailer, adapter: Swoosh.Adapters.Local

####################################
# DB Cache
####################################
config :poffee, Poffee.DBCache,
  # When using :shards as backend
  # backend: :shards,
  # GC interval for pushing new generation: 12 hrs
  gc_interval: :timer.hours(12),
  # Max 1 million entries in cache
  max_size: 1_000_000,
  # Max 1.0 GB of memory
  allocated_memory: 1_000_000_000,
  # GC min timeout: 10 sec
  gc_cleanup_min_timeout: :timer.seconds(10),
  # GC max timeout: 10 min
  gc_cleanup_max_timeout: :timer.minutes(10)

####################################
# FunWithFlags 
####################################
config :fun_with_flags, :cache,
  enabled: true,
  # in seconds (10 mins)
  ttl: 600

# see https://github.com/tompave/fun_with_flags/issues/35#issuecomment-466809949
config :fun_with_flags, :cache_bust_notifications,
  enabled: true,
  adapter: FunWithFlags.Notifications.PhoenixPubSub,
  client: Poffee.PubSub

config :fun_with_flags, :persistence,
  adapter: FunWithFlags.Store.Persistent.Ecto,
  repo: Poffee.Repo

####################################
# Admin
####################################
# Enable admin routes for dashboard and mailbox
config :poffee, admin_routes: true

####################################
# esbuild (the version is required)
####################################
# config :esbuild,
#   version: "0.17.11",
#   default: [
#     args:
#       ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
#     cd: Path.expand("../assets", __DIR__),
#     env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
#   ]

####################################
# tailwind (the version is required)
####################################
config :tailwind,
  version: "3.2.7",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

####################################
# Logger
####################################
# Configures Elixir's Logger
config :logger, :console,
  format: "[$date $time] $metadata[$level] $message\n",
  metadata: [:request_id]

config :logger, :default_handler,
  config: [
    file: ~c"log/poffee.log",
    filesync_repeat_interval: 5000,
    file_check: 5000,
    max_no_bytes: 10_000_000,
    max_no_files: 5,
    compress_on_rotate: true
  ]

#  config :logger,
#   handle_otp_reports: true,
#   handle_sasl_reports: true

####################################
# Use Jason for JSON parsing in Phoenix
####################################
config :phoenix, :json_library, Jason

####################################
# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
####################################
import_config "#{config_env()}.exs"
