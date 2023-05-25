defmodule PoffeeWeb.SaveRequestUri do
  require Logger

  def on_mount(:save_request_uri, _params, _session, socket) do
    {:cont,
     Phoenix.LiveView.attach_hook(
       socket,
       :save_request_path,
       :handle_params,
       &save_request_path/3
     )}
  end

  defp save_request_path(_params, url, socket) do
    %{path: path, query: query} = URI.parse(url)

    uri = path <> if query, do: "?" <> query, else: ""
    # Logger.debug("[save_request_path] setting current_uri to #{uri}")

    {:cont, Phoenix.Component.assign(socket, :current_uri, uri)}
  end
end
