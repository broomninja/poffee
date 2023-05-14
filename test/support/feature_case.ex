defmodule PoffeeWeb.FeatureCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a full browser.

  If the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use TestingLiveViewWallabyWeb.FeatureCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      use Wallaby.Feature

      import Poffee.AccountsFixtures
      import PoffeeWeb.Factory
      import PoffeeWeb.FeatureCase
      import Wallaby.Query

      alias PoffeeWeb.Router.Helpers, as: Routes

      @moduletag :e2e

      @endpoint PoffeeWeb.Endpoint

      setup _ do
        # the checkout call is done from "use Wallaby.Feature" above already, 
        # calling it again will result in:
        # ** (MatchError) no match of right hand side value: {:already, :owner}
        # :ok = Ecto.Adapters.SQL.Sandbox.checkout(Poffee.Repo)

        Ecto.Adapters.SQL.Sandbox.mode(Poffee.Repo, {:shared, self()})

        metadata = Phoenix.Ecto.SQL.Sandbox.metadata_for(Poffee.Repo, self())

        on_exit(fn -> Application.put_env(:wallaby, :js_logger, :stdio) end)

        {:ok, session} = Wallaby.start_session(metadata: metadata)
        {:ok, session: session}
      end
    end
  end

  def enable_latency_sim(session, latency) do
    Application.put_env(:wallaby, :js_logger, nil)
    Wallaby.Browser.execute_script(session, "liveSocket.enableLatencySim(#{latency})")
  end

  def disable_latency_sim(session) do
    Wallaby.Browser.execute_script(session, "liveSocket.disableLatencySim()")
  end
end
