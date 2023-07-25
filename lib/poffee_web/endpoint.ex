defmodule PoffeeWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :poffee

  if Application.compile_env(:poffee, :use_sandbox) do
    plug Phoenix.Ecto.SQL.Sandbox
  end

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  # @session_options [
  #   store: :cookie,
  #   key: "_poffee_key",
  #   # 300 years
  #   max_age: 9_999_999_999,
  #   signing_salt: "USFvY1wK",
  #   encryption_salt: "93kjdj33-s77sd22",
  #   key_length: 64,
  #   same_site: "Lax"
  # ]

  # Using PhoenixLiveSession as session store
  @session_options [
    store: PhoenixLiveSession,
    key: "_poffee_key",
    signing_salt: "X3SUSFvY1wK",
    pub_sub: Poffee.PubSub
  ]

  socket("/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [:user_agent, session: @session_options]]
  )

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :poffee,
    gzip: false,
    only: PoffeeWeb.static_paths()

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :poffee
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  # replace with a custom parser that can preserve raw_body for webhook verfications
  plug :parse_body

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug PoffeeWeb.Router

  ###################
  # :parse_body
  ###################
  parse_body_opts = [
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()
  ]

  @parser_without_cache Plug.Parsers.init(parse_body_opts)
  @parser_with_cache Plug.Parsers.init(
                       [body_reader: {PoffeeWeb.BodyReader, :cache_raw_body, []}] ++
                         parse_body_opts
                     )

  # All endpoints that start with "webhooks" have their body cached.
  defp parse_body(%{path_info: ["webhooks" | _]} = conn, _),
    do: Plug.Parsers.call(conn, @parser_with_cache)

  defp parse_body(conn, _),
    do: Plug.Parsers.call(conn, @parser_without_cache)
end
