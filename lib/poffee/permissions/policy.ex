defmodule Poffee.Permissions.Policy do
  use LetMe.Policy

  object :user do
    action :assign_role do
      allow role: :role_admin
    end

    action :edit do
      allow role: :role_admin
      allow :myself
    end
  end
end
