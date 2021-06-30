defmodule SwarmBackgroundJob.DatabaseCleaner do
  use GenServer
  require Logger

  alias __MODULE__.Runner

  @impl GenServer
  def init(args \\ []) do
    timeout = Keyword.get(args, :timeout)

    schedule(timeout)

    {:ok, timeout}
  end

  @impl GenServer
  def handle_info(:execute, timeout) do
    Task.start(Runner, :execute, [])

    schedule(timeout)

    {:noreply, timeout}
  end

  @impl GenServer
  def handle_info({:swarm, :die}, state) do
    {:stop, :shutdown, state}
  end

  @impl GenServer
  def handle_call({:swarm, :begin_handoff}, _from, state) do
    {:reply, :restart, state}
  end

  @impl GenServer
  def handle_cast({:swarm, :resolve_conflict, _}, state) do
    {:noreply, state}
  end

  defp schedule(timeout) do
    Process.send_after(self(), :execute, timeout)
  end
end
