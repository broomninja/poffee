defmodule Poffee.Constant do
  import Constants

  # User
  const(:email_max_length, 250)
  const(:username_min_length, 2)
  const(:username_max_length, 30)
  const(:password_min_length, 8)
  const(:password_max_length, 125)

  # UserAuth
  const(:require_authenticated_text, "Please login to proceed.")
  const(:require_admin_text, "You do not have permission to view the requested page.")

  # Feedback
  const(:feedback_title_min_length, 1)
  const(:feedback_title_max_length, 200)
  const(:feedback_content_min_length, 2)
  const(:feedback_content_max_length, 1000)
  const(:feedback_default_sort_by, "oldest")

  # Comment
  const(:comment_content_min_length, 1)
  const(:comment_content_max_length, 500)
  const(:comment_default_sort_by, "oldest")
end
