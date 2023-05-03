defmodule PoffeeWeb.Router do
  use PoffeeWeb, :router
  use AshAuthentication.Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {PoffeeWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_from_session
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :load_from_bearer
  end

  scope "/", PoffeeWeb do
    pipe_through :browser

    ash_authentication_live_session do
      live "/newsignin", CustomSignInLive
    end

    sign_in_route(
      on_mount: [
        {PoffeeWeb.Auth.LiveUserAuth, :live_user_auth__load_user},
        {PoffeeWeb.Auth.LiveUserAuth, :live_user_auth__no_user}
      ],
      live_view: PoffeeWeb.Auth.SignInLive,
      overrides: [PoffeeWeb.Auth.AuthOverrides, PoffeeWeb.Auth.OverridesDefault]
    )

    sign_out_route AuthController
    auth_routes_for Poffee.Accounts.User, to: AuthController
    reset_route []
  end

  scope "/", PoffeeWeb do
    pipe_through :browser

    get "/", PageController, :demo
    # get "/demo", PageController, :demo
  end

  # Other scopes may use custom stacks.
  # scope "/api", PoffeeWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:poffee, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: PoffeeWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
