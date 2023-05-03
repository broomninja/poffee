defmodule Poffee.Accounts.Registry do
  use Ash.Registry, extensions: [Ash.Registry.ResourceValidations]

  entries do
    entry Poffee.Accounts.User
    entry Poffee.Accounts.Token
  end
end
