defmodule Poffee.DBCache do
  use Nebulex.Cache,
    otp_app: :poffee,
    adapter: Application.compile_env(:poffee, :nebulex_adapter, Nebulex.Adapters.Local),
    default_key_generator: __MODULE__

  @behaviour Nebulex.Caching.KeyGenerator

  @impl true
  def generate(mod, fun, args), do: :erlang.phash2({mod, fun, args})
end
