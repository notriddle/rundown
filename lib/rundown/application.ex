defmodule Rundown.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = :rundown
    |> Application.get_env(:workers)
    |> Enum.map(&Supervisor.child_spec({Rundown.Worker, &1}, id: &1))

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Rundown.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
