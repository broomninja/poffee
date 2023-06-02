defmodule Poffee.Constant do
  import Constants

  # User
  const(:email_max_length, 250)
  const(:username_min_length, 4)
  const(:username_max_length, 30)
  const(:password_min_length, 8)
  const(:password_max_length, 125)

  # UserAuth
  const(:require_authenticated_text, "Please login to proceed.")
  const(:require_admin_text, "You do not have permission to view the requested page.")
end
