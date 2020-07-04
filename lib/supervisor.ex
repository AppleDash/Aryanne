defmodule IrcBot.Supervisor do
  use Supervisor

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, {:ok, arg})
  end

  @impl true
  def init(arg) do
    children = [
      IrcBot.IrcBot
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end