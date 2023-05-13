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

config :poffee, Poffee.Repo, migration_primary_key: [type: :uuid]

####################################
# Web Endpoint
####################################
config :poffee, PoffeeWeb.Endpoint,
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
config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:../../broomninja/phoenix_live_view/* --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

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
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

####################################
# Use Jason for JSON parsing in Phoenix
####################################
config :phoenix, :json_library, Jason

####################################
# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
####################################
import_config "#{config_env()}.exs"
