defmodule Poffee.Permissions.Policy.Checks do
  alias Poffee.Accounts.User

  def myself(%User{id: id}, %User{id: id}, _) when is_binary(id), do: true

  def role(%User{role: role}, _object, role), do: true
  def role(_, _, _), do: false

  # def own_comment(%User{} = user, %Comment{} = comment), do: comment.user_id == user.id
end
