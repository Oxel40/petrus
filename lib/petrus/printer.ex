defmodule Petrus.PrinterBroker do
  use GenServer

  ## Server "backend"

  @impl true
  def init(:ok) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:register_agent, pid}, _from, state) do
    IO.puts("hello from gen server")
    if Map.has_key?(state, :agent) and Process.alive?(state[:agent]) do
      {:reply, {:error, "agent already registered"}, state}
    else
      {:reply, {:ok, pid}, Map.put(state, :agent, pid)}
    end
  end

  @impl true
  def handle_call({:print_binary, bin}, _from, state) do
    if Map.has_key?(state, :agent) and Process.alive?(state[:agent]) do
      {:reply, send(state[:agent], {:print_binary, bin}), state}
    else
      {:reply, {:error, "no agent avalibe"}, state}
    end
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
end
