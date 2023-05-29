defmodule PoffeeWeb.Features.HomeAuthTest do
  use PoffeeWeb.FeatureCase, async: true

  setup do
    # create a registered user
    %{user: user_fixture()}
  end

  describe "<home page create account>" do
    feature "users should be able to create an account and then login and return to the home page",
            %{session: session} do
      user = %{email: "user@mail.com", password: "password"}

      session
      |> visit("/")
      |> click(button("Sign in"))
      |> click(link("Sign up"))
      |> fill_in(text_field("Email"), with: user.email)
      |> fill_in(text_field("Password"), with: user.password)
      |> click(button("Create an account"))
      |> click(css(".tabler-user-cog"))
      |> assert_has(css("button", text: user.email))
    end

    @tag :skip
    feature "users should be redirected to the requested page after registration",
            %{session: _session} do
    end

    @tag :skip
    feature "users should be redirected to the requested page after login",
            %{session: _session} do
    end
  end

  # defp sleep(session) do
  #   Process.sleep(400)
  #   session
  # end
end
