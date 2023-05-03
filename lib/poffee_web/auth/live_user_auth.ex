defmodule PoffeeWeb.Auth.LiveUserAuth do
  @moduledoc """
  Helpers for authenticating users in liveviews
  """

  import Phoenix.Component
  import AshAuthentication.Phoenix.Components.Helpers
  use PoffeeWeb, :verified_routes

  alias AshAuthentication.Info

  def on_mount(
        :live_user_auth__load_user,
        _params,
        session,
        socket
      ) do
    otp_app = otp_app_from_socket(socket)

    resources =
      otp_app
      |> AshAuthentication.authenticated_resources()
      |> Stream.map(&{to_string(Info.authentication_subject_name!(&1)), &1})
      |> Map.new()

    socket =
      session
      |> Enum.reduce(socket, fn {key, value}, socket ->
        with {:ok, resource} <- Map.fetch(resources, key),
             {:ok, user} <-
               AshAuthentication.subject_to_user(value, resource, tenant: session["tenant"]),
             {:ok, subject_name} <-
               Info.authentication_subject_name(resource) do
          assign(socket, String.to_existing_atom("current_#{subject_name}"), user)
        else
          _ -> socket
        end
      end)

    {:cont, socket}
  end

  def on_mount(:live_user_auth__user_optional, _params, _session, socket) do
    if socket.assigns[:current_user] do
      {:cont, socket}
    else
      {:cont, assign(socket, :current_user, nil)}
    end
  end

  def on_mount(:live_user_auth__user_required, _params, _session, socket) do
    if socket.assigns[:current_user] do
      {:cont, socket}
    else
      {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/sign-in")}
    end
  end

  def on_mount(:live_user_auth__no_user, _params, _session, socket) do
    IO.inspect(socket.assigns, label: "on_mount: current user")

    if socket.assigns[:current_user] do
      {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/")}
    else
      {:cont, assign(socket, :current_user, nil)}
    end
  end
end
