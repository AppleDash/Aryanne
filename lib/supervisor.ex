defmodule IrcBot.Supervisor do
  use Supervisor

  def start_link(config) do
    Supervisor.start_link(__MODULE__, {:ok, config}, [])
  end

  @impl true
  def init(config) do
    children = [
      {IrcBot.Command.CommandHandler, name: :command_handler},
      {IrcBot.IrcBot, config}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
