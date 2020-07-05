defmodule IrcBot.CommandHandler do
  use GenServer

  # client API

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def handle_command(server, context) do
    GenServer.call(server, {:command, context})
  end

  # server stuff, where the magic happens

  @impl true
  def init(:ok) do
    {:ok, nil}
  end

  @impl true
  def handle_call({:command, context}, _from, state) do
    {:reply, case context do
        %{command: "ping"} -> {:respond, "Pong!"}
        _ -> {:nothing}
    end, state}
  end
end