defmodule IrcBot.Connector do
  @moduledoc """
  The thing that actually connects to IRC  
  """
  use GenServer

  def init({:ok, config}) do
    socket = Socket.TCP.connect!(config.host, config.port, packet: :line, mode: :active)

    {:ok, %{socket: socket}}
  end

  @impl true
  def handle_info(msg, %{socket: socket} = state) do
    with {:tcp, ^socket, data} <- msg do
      # process_line(socket, Line.parse!(data))
    end

    {:noreply, state}
  end
end
