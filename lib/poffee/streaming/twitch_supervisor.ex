defmodule Poffee.Streaming.TwitchSupervisor do
  @moduledoc """
  Supervisor responsible 
  """

  use Supervisor

  alias Poffee.Env

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      {Task.Supervisor, name: Poffee.Streaming.TaskSupervisor},
      {Poffee.Streaming.TwitchApiConnector, twitch_api_client: Env.twitch_api_client()},
      Poffee.Streaming.TwitchSubscriptionManager,
      Poffee.Streaming.TwitchLiveStreamers,
      Poffee.Social.MostActiveStore
    ]

    # :one_for_one strategy: if a child process crashes, only that process is restarted.
    Supervisor.init(children, strategy: :one_for_one)
  end
end
