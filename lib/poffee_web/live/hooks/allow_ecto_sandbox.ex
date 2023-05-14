defmodule PoffeeWeb.Hooks.AllowEctoSandbox do
  import Phoenix.Component
  import Phoenix.LiveView

  @allow_sandbox Application.compile_env(:poffee, :use_sandbox)

  def on_mount(:default, _params, _session, socket) do
    if @allow_sandbox, do: allow_ecto_sandbox(socket)
    {:cont, socket}
  end

  defp allow_ecto_sandbox(socket) do
    %{assigns: %{phoenix_ecto_sandbox: metadata}} =
      assign_new(socket, :phoenix_ecto_sandbox, fn ->
        if connected?(socket), do: get_connect_info(socket, :user_agent)
      end)

    Phoenix.Ecto.SQL.Sandbox.allow(metadata, Ecto.Adapters.SQL.Sandbox)
  end
end
