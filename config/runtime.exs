import Config

[__DIR__ | ~w(config_helper.exs)]
|> Path.join()
|> Code.eval_file()

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/poffee start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER") do
  config :poffee, PoffeeWeb.Endpoint, server: true
end

config :poffee, compile_env: config_env()

########################
### LiveSvelte
########################
config :poffee, :live_svelte,
  enable_ssr: ConfigHelper.get_boolean_env("LIVESVELTE_ENABLE_SSR", false)

########################
### Socket Check Origin
########################
if config_env() == :dev do
  config :poffee, PoffeeWeb.Endpoint,
    check_origin: ConfigHelper.get_list_env!("ENDPOINT_CHECK_ORIGIN")
end

########################
### PRODUCTION ENV
########################
if config_env() == :prod do
  database_url = ConfigHelper.get_env!("DATABASE_URL")

  maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

  %URI{host: database_host} = URI.parse(database_url)

  config :poffee, Poffee.Repo,
    ssl: true,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    ssl_opts: [
      verify: :verify_peer,
      cacertfile: Path.join(:code.priv_dir(:poffee), "cert/cacert.pem"),
      server_name_indication: to_charlist(database_host),
      customize_hostname_check: [
        match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
      ]
    ],
    socket_options: maybe_ipv6

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base = ConfigHelper.get_env!("SECRET_KEY_BASE")

  host = System.get_env("PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :poffee, PoffeeWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    check_origin: ConfigHelper.get_list_env!("ENDPOINT_CHECK_ORIGIN"),
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/plug_cowboy/Plug.Cowboy.html
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base

  ########################
  ### Twitch
  ########################
  config :poffee, :twitch,
    client_id: ConfigHelper.get_env!("TWITCH_CLIENT_ID"),
    client_secret: ConfigHelper.get_env!("TWITCH_CLIENT_SECRET"),
    callback_webhook_uri: ConfigHelper.get_env!("TWITCH_CALLBACK_WEBHOOK_URI")

  # ## SSL Support
  #
  # To get SSL working, you will need to add the `https` key
  # to your endpoint configuration:
  #
  #     config :poffee, PoffeeWeb.Endpoint,
  #       https: [
  #         ...,
  #         port: 443,
  #         cipher_suite: :strong,
  #         keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
  #         certfile: System.get_env("SOME_APP_SSL_CERT_PATH")
  #       ]
  #
  # The `cipher_suite` is set to `:strong` to support only the
  # latest and more secure SSL ciphers. This means old browsers
  # and clients may not be supported. You can set it to
  # `:compatible` for wider support.
  #
  # `:keyfile` and `:certfile` expect an absolute path to the key
  # and cert in disk or a relative path inside priv, for example
  # "priv/ssl/server.key". For all supported SSL configuration
  # options, see https://hexdocs.pm/plug/Plug.SSL.html#configure/1
  #
  # We also recommend setting `force_ssl` in your endpoint, ensuring
  # no data is ever sent via http, always redirecting to https:
  #
  #     config :poffee, PoffeeWeb.Endpoint,
  #       force_ssl: [hsts: true]
  #
  # Check `Plug.SSL` for all available options in `force_ssl`.

  # ## Configuring the mailer
  #
  # In production you need to configure the mailer to use a different adapter.
  # Also, you may need to configure the Swoosh API client of your choice if you
  # are not using SMTP. Here is an example of the configuration:
  #
  #     config :poffee, Poffee.Mailer,
  #       adapter: Swoosh.Adapters.Mailgun,
  #       api_key: System.get_env("MAILGUN_API_KEY"),
  #       domain: System.get_env("MAILGUN_DOMAIN")
  #
  # For this example you need include a HTTP client required by Swoosh API client.
  # Swoosh supports Hackney and Finch out of the box:
  #
  #     config :swoosh, :api_client, Swoosh.ApiClient.Hackney
  #
  # See https://hexdocs.pm/swoosh/Swoosh.html#module-installation for details.
end
