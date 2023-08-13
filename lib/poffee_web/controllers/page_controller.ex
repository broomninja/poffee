defmodule PoffeeWeb.PageController do
  use PoffeeWeb, :controller

  # require Logger

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def demo(conn, _params) do
    # Test page
    # Logger.error("#{inspect(conn)}")
    render(conn, :demo, layout: false)
  end
end
