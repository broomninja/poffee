defmodule PoffeeWeb.Router do
  use PoffeeWeb, :router

  import PoffeeWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {PoffeeWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PoffeeWeb do
    pipe_through :browser

    get "/", PageController, :demo
    get "/demo", PageController, :demo
  end

  # Other scopes may use custom stacks.
  # scope "/api", PoffeeWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview
  if Application.compile_env(:poffee, :admin_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/admin" do
      pipe_through [:browser, :require_authenticated_admin]

      live_session :require_authenticated_admin,
        on_mount: [
          PoffeeWeb.Hooks.AllowEctoSandbox,
          {PoffeeWeb.UserAuthLive, :ensure_admin}
        ] do
      end

      forward "/mailbox", Plug.Swoosh.MailboxPreview

      live_dashboard "/system",
        ecto_repos: [Poffee.Repo],
        ecto_psql_extras_options: [
          long_running_queries: [threshold: "200 milliseconds"]
        ],
        # metrics_history:
        #   if(Config.env() == :dev, do: {PoffeeWeb.TelemetryStorage, :metrics_history, []}),
        metrics: PoffeeWeb.Telemetry
    end
  end

  # # Wallaby
  # live_session :default, on_mount: PoffeeWeb.Hooks.AllowEctoSandbox do
  #   scope "/", PoffeeWeb do
  #     pipe_through :browser
  #   end
  # end

  ## Authentication routes

  scope "/", PoffeeWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [
        PoffeeWeb.Hooks.AllowEctoSandbox,
        {PoffeeWeb.UserAuthLive, :redirect_if_user_is_authenticated}
      ] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", PoffeeWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [
        PoffeeWeb.Hooks.AllowEctoSandbox,
        {PoffeeWeb.UserAuthLive, :ensure_authenticated}
      ] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
      live "/protected", DemoLive, :new
    end
  end

  scope "/", PoffeeWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [
        PoffeeWeb.Hooks.AllowEctoSandbox,
        {PoffeeWeb.UserAuthLive, :mount_current_user}
      ] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
      live "/demolive", DemoLive, :new
    end
  end
end
