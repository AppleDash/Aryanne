defmodule IrcBot.Command.CommandHandler do
  use GenServer

  alias IrcBot.Derpibooru

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
        %{command: "heil"} -> handle_heil()
        _ -> {:nothing}
    end, state}
  end

  # handler for !heil
  defp handle_heil() do
    image = Derpibooru.random_image!("sieg heil")

    {:respond, "Sieg heil! https://derpibooru.org/images/" <> Integer.to_string(image["id"])}
  end
end