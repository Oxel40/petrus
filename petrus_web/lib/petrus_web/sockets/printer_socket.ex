defmodule PetrusWeb.PrinterSocket do
  @behaviour Phoenix.Socket.Transport
  alias Petrus.PrinterBroker, as: PB
  require Logger

  def child_spec(_opts) do
    # We won't spawn any process, so let's return a dummy task
    %{id: __MODULE__, start: {Task, :start_link, [fn -> :ok end]}, restart: :transient}
  end

  def connect(%{connect_info: %{x_headers: x_headers}} = state) do
    Logger.info("Printer agent trying to connect")

    case Enum.find(x_headers, fn {k, _v} -> k == "x-printer-auth" end) do
      {"x-printer-auth", auth_token} ->
        Logger.info("x-printer-auth header found")
        if secret() == auth_token do
          Logger.info("connected")
          {:ok, state}
        else
          Logger.info("invalid secret")
          :error
        end

      _ ->
        Logger.info("x-printer-auth header not found")
        :error
    end
  end

  def connect(_state) do
    # no x-header for authentication
    Logger.info("Printer agent trying to connect but without a x-header for auth")
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
