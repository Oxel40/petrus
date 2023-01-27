defmodule Petrus.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      PetrusWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Petrus.PubSub},
      # Start the Endpoint (http/https)
      PetrusWeb.Endpoint,
      # Start a worker by calling: Petrus.Worker.start_link(arg)
      # {Petrus.Worker, arg}
      # Registry
      # {Registry, keys: :unique, name: Petrus.Registry}
      Petrus.PrinterBroker
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Petrus.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PetrusWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
