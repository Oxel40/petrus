defmodule PetrusWeb.EchoSocket do
  @behaviour Phoenix.Socket.Transport
  alias Petrus.PrinterBroker, as: PB
  require Logger

  def child_spec(_opts) do
    # We won't spawn any process, so let's return a dummy task
    %{id: __MODULE__, start: {Task, :start_link, [fn -> :ok end]}, restart: :transient}
  end

  def connect(%{connect_info: %{x_headers: [{"x-printer-auth", auth_token}]}} = state) do
    # Callback to retrieve relevant data from the connection.
    # The map contains options, params, transport and endpoint keys.
    Logger.info("Printer agent trying to connect\nstate: #{inspect(state, pretty: true)}")

    if secret() == auth_token do
      {:ok, state}
    else
      :error
    end
  end

  def connect(_state) do
    # no header for authentication
    :error
  end

  def init(state) do
    # Now we are effectively inside the process that maintains the socket.
    Logger.info("init")
    res = PB.register_agent(self())
    Logger.info(inspect(res))

    case res do
      {:ok, _} -> {:ok, state}
      {:error, {:already_registered, _}} -> {:error, state}
    end
  end

  def handle_in({text, _opts}, state) do
    # Logger.info("receved status report")
    PB.set_agent_status(text)
    {:ok, state}
  end

  def handle_info({:print_binary, bin}, state) do
    Logger.info("sending binary for printing")
    {:push, {:binary, bin}, state}
  end

  def handle_info(:clear_queue, state) do
    Logger.info("sending clear queue request")
    {:push, {:text, "clear queue"}, state}
  end

  def handle_info({:printer_status, _}, state) do
    {:ok, state}
  end

  def handle_info(_, state) do
    Logger.info("in socket info")
    {:ok, state}
  end

  def handle_control({nil, [opcode: :ping]}, state) do
    Logger.info("control frame ping")
    {:reply, :ok, {nil, [opcode: :pong]}, state}
  end

  def handle_control({nil, [opcode: :pong]}, state) do
    Logger.info("control frame pong")
    {:reply, :ok, {:text, "ping"}, state}
  end

  def terminate(_reason, _state) do
    Logger.info("terminating")
    :ok
  end

  defp secret() do
    Application.fetch_env!(:petrus, :agent_secret)
  end
end
