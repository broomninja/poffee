defmodule Poffee.Constant do
  import Constants

  const(:email_max_length, 250)

  const(:require_authenticated_text, "Please login to proceed.")
  const(:require_admin_text, "You do not have permission to view the requested page.")
end
