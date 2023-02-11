defmodule Petrus.PrinterBroker do
  use GenServer

  ## Server "backend"

  @impl true
  def init(:ok) do
    {:ok, %{agent_status: ""}}
  end

  @impl true
  def handle_call({:register_agent, pid}, _from, state) do
    if active_agent?(state) do
      {:reply, {:error, "agent already registered"}, state}
    else
      {:reply, {:ok, pid}, Map.put(state, :agent, pid)}
    end
  end

  @impl true
  def handle_call({:print_binary, bin}, _from, state) do
    if active_agent?(state) do
      {:reply, send(state[:agent], {:print_binary, bin}), state}
    else
      {:reply, {:error, "no agent avalibe"}, state}
    end
  end

  @impl true
  def handle_call(:agent_status?, _from, state) do
    if active_agent?(state) do
      {:reply, {:ok, state[:agent_status]}, state}
    else
      {:reply, {:error, "no agent avalibe"}, state}
    end
  end

  @impl true
  def handle_call({:set_agent_status, status}, _from, state) do
    if active_agent?(state) do
      state_ = Map.put(state, :agent_status, status)
      {:reply, {:ok, state_[:agent_status]}, state_}
    else
      {:reply, {:error, "no agent avalibe"}, state}
    end
  end

  @impl true
  def handle_call(:clear_queue, _from, state) do
    if active_agent?(state) do
      {:reply, send(state[:agent], :clear_queue), state}
    else
      {:reply, {:error, "no agent avalibe"}, state}
    end
  end

  defp active_agent?(state) do
    Map.has_key?(state, :agent) and Process.alive?(state[:agent])
  end

  ## Client API

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, [name: :_petrus_printer_broker] ++ opts)
  end

  def register_agent(pid) do
    GenServer.call(:_petrus_printer_broker, {:register_agent, pid})
  end

  def print_binary(bin) do
    GenServer.call(:_petrus_printer_broker, {:print_binary, bin})
  end

  def agent_status() do
    GenServer.call(:_petrus_printer_broker, :agent_status?)
  end

  def set_agent_status(status) do
    GenServer.call(:_petrus_printer_broker, {:set_agent_status, status})
  end

  def clear_queue() do
    GenServer.call(:_petrus_printer_broker, :clear_queue)
  end
end
