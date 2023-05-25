defmodule PoffeeWeb.SaveRequestUri do
  @moduledoc """

  url is only available in handle_params of a liveview cycle, here we use attach_hook to extract
  the url info and put it into socket.assigns

  See: https://elixirforum.com/t/get-the-url-from-a-liveview-request/47356/4
  
  """

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
