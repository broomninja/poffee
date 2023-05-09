{:ok, _} = Application.ensure_all_started(:wallaby)
Application.put_env(:wallaby, :base_url, PoffeeWeb.Endpoint.url())

{:ok, _} = Application.ensure_all_started(:ex_machina)

ExUnit.configure(exclude: [:e2e])
ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(Poffee.Repo, :manual)
