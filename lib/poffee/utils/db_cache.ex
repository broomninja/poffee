defmodule Poffee.DBCache do
  use Nebulex.Cache,
    otp_app: :poffee,
    adapter: Nebulex.Adapters.Local
end
