defmodule KVServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @default_port "4040"

  def start(_type, _args) do
    port = String.to_integer(System.get_env("KV_PORT") || @default_port)
    children = [
      {Task, fn -> KVServer.accept(port) end},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: KVServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
