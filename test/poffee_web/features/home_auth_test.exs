defmodule PoffeeWeb.Features.HomeAuthTest do
  use PoffeeWeb.FeatureCase, async: true

  describe "<home page create account>" do
    feature "users should be able to create an account and then login and return to the home page",
            %{session: session} do
      user = %{email: "user@mail.com", password: "passwordpassword"}

      session
      |> visit("/")
      |> click(link("Log in"))
      |> click(link("Sign up"))
      |> fill_in(text_field("Email"), with: user.email)
      |> fill_in(text_field("Password"), with: user.password)
      |> click(button("Create an account"))
      |> assert_has(css("li", text: user.email))
    end
  end

  # defp sleep(session) do
  #   Process.sleep(400)
  #   session
  # end
end
