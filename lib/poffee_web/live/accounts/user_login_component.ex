defmodule PoffeeWeb.UserLoginComponent do
  use PoffeeWeb, :live_component

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Sign in to account
        <:subtitle>
          Don't have an account?
          <.link
            navigate={
              Routes.user_registration_path(PoffeeWeb.Endpoint, :new,
                user_return_to: assigns[:user_return_to] || []
              )
            }
            class="font-semibold text-brand hover:underline"
          >
            Sign up
          </.link>
          for an account now.
        </:subtitle>
      </.header>

      <.simple_form for={@form} id="login_form" action={~p"/users/log_in"} phx-update="ignore">
        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Password" required />
        <.input field={@form[:user_return_to]} type="hidden" value={assigns[:user_return_to]} />

        <:actions>
          <%!-- <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" /> --%>
          <.link href={~p"/users/reset_password"} class="text-sm font-semibold">
            Forgot your password?
          </.link>
        </:actions>
        <:actions>
          <.button phx-disable-with="Signing in..." class="w-full">
            Sign in <span aria-hidden="true">→</span>
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end
end
