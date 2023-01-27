defmodule PetrusWeb.EchoSocket do
  @behaviour Phoenix.Socket.Transport
  alias Petrus.PrinterBroker, as: PB

  def child_spec(_opts) do
    # We won't spawn any process, so let's return a dummy task
    %{id: __MODULE__, start: {Task, :start_link, [fn -> :ok end]}, restart: :transient}
  end

  def connect(state) do
    # Callback to retrieve relevant data from the connection.
    # The map contains options, params, transport and endpoint keys.
    # Logger.info("Websocket connected")
    {:ok, state}
  end

  def init(state) do
    # Now we are effectively inside the process that maintains the socket.
    IO.puts("init")
    IO.inspect(state)
    res = PB.register_agent(self())
    IO.inspect(res)

    case res do
      {:ok, _} -> {:ok, state}
      {:error, {:already_registered, _}} -> {:error, state}
    end

    # {:ok, state}
  end

  def handle_in({text, _opts}, state) do
    {:reply, :ok, {:text, text <> " - from server"}, state}
  end

  def handle_info({:print_binary, _bin}, state) do
    IO.puts("in special socket info")
    # {:push, {:text, "Print request"}, state}
    {:push, {:binary, "Print request"}, state}
  end

  def handle_info(_, state) do
    IO.puts("in socket info")
    {:ok, state}
  end

  def terminate(_reason, _state) do
    IO.puts("terminating")
    :ok
  end
end
