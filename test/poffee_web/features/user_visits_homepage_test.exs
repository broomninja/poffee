defmodule PoffeeWeb.Features.UserVisitsHomepageTest do
  use PoffeeWeb.FeatureCase, async: true

  describe "home page" do
    feature "Demo text will be displayed",
            %{session: session} do
      session
      |> visit("/")
      |> assert_has(Query.text("Poffee Demo"))
    end
  end
end
