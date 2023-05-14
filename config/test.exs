import Config

####################################
# Repo
####################################
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :poffee, Poffee.Repo,
  username: "pgdb_user_poffee",
  password: "pgdb_password_poffee",
  hostname: "localhost",
  database: "poffee_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :poffee, PoffeeWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "KGG58nCIpaEd/us4W7zTrspabYKwQYyE8v7vFUeEqk5mXkatRC3q5MVhcoRyv7a8",
  server: true

####################################
# Wallaby E2E
####################################
config :poffee, use_sandbox: true

config :wallaby,
  otp_app: :poffee,
  screenshot_on_failure: true,
  driver: Wallaby.Chrome,
  chromedriver: [
    path: "/usr/local/bin/chromedriver",
    headless: true
  ]

####################################
# Mailer / SMTP
####################################
# In test we don't send emails.
config :poffee, Poffee.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

####################################
# Logger
####################################
# Print only warnings and errors during test
config :logger, level: :warning

####################################
# Misc
####################################
# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1