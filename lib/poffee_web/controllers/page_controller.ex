defmodule PoffeeWeb.PageController do
  use PoffeeWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def demo(conn, _params) do
    # Test page
    render(conn, :demo, layout: false)
  end
end
