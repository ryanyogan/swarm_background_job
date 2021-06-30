defmodule SwarmBackgroundJob.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Cluster.Supervisor, [topologies(), [name: SwarmBackgroundJob.ClusterSupervisor]]},
      SwarmBackgroundJob.DatabaseCleaner.Supervisor,
      {SwarmBackgroundJob.DatabaseCleaner.Starter, [timeout: :timer.seconds(2)]}
    ]

    opts = [strategy: :one_for_one, name: SwarmBackgroundJob.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp topologies do
    [
      background_job: [
        strategy: Cluster.Strategy.Gossip
      ]
    ]
  end
end
