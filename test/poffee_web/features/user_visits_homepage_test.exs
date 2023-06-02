defmodule PoffeeWeb.Features.UserVisitsHomepageTest do
  use PoffeeWeb.FeatureCase, async: true

  describe "home page" do
    feature "Sign in button will be displayed",
            %{session: session} do
      session
      |> visit("/")
      |> assert_has(link("Brand", minimum: 1))
      |> assert_has(css("button", text: "Sign in"))
    end
  end
end
