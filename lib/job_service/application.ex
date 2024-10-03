defmodule JobService.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Bandit, plug: JobService.Router}
      # Starts a worker by calling: JobService.Worker.start_link(arg)
      # {JobService.Worker, arg}
    ]

    children =
      if Mix.env() == :test do
        children
      else
        [JobService.Repo | children]
      end

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: JobService.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
