defmodule PoffeeWeb.Auth.AuthOverrides do
  @moduledoc false
  use AshAuthentication.Phoenix.Overrides
  alias AshAuthentication.Phoenix.Components

  override PoffeeWeb.Components.SignIn do
    set :show_banner, false
  end

  override Components.Banner do
    # set :root_class, "hidden"
    set :image_url, "/images/logo.png"
    # TODO: use a diff image for dark
    set :dark_image_url, "/images/logo.png"
  end

  override Components.Reset do
    # set :show_banner, false
  end
end
