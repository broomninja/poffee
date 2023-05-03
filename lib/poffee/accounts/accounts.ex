defmodule Poffee.Accounts do
  use Ash.Api

  resources do
    registry Poffee.Accounts.Registry
  end
end
