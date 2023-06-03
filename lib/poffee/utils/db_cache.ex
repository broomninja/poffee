defmodule Poffee.DBCache do
  use Nebulex.Cache,
    otp_app: :poffee,
    adapter: Application.compile_env(:poffee, :nebulex_adapter, Nebulex.Adapters.Local)
end
