defmodule PoffeeWeb.ErrorJSONTest do
  use PoffeeWeb.ConnCase, async: false

  test "renders 404" do
    assert PoffeeWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert PoffeeWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
