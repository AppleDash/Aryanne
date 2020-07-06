defmodule IrcBot.IrcBot do
  use GenServer

  alias IrcBot.Irc.MessageContext
  alias IrcBot.Command.CommandHandler
  alias IrcBot.Command.CommandContext

  @impl true
  def init({:ok, config}) do
    socket = Socket.TCP.connect!(config.host, config.port, packet: :line, mode: :active)

    puts!(socket, "NICK " <> config.nick)
    puts!(socket, "USER " <> config.nick <> " * * :" <> config.nick)

    {:ok, %{socket: socket}}
  end

  def start_link(config) do
    GenServer.start_link(__MODULE__, config)
  end

  @impl true
  def handle_info(msg, %{socket: socket} = state) do
    with {:tcp, ^socket, data} <- msg do
      process_line(socket, Line.parse!(data))
    end

    {:noreply, state}
  end

  defp handle_command(socket, context, [cmd | args]) do
    case CommandHandler.handle_command(:command_handler, %CommandContext{command: cmd, args: args}) do
      {:respond, response} -> privmsg(socket, MessageContext.reply_target(context), response)
      {:nothing} -> nil
    end
  end

  defp handle_privmsg(socket, line) do
    [target, message] = line.params

    context = %MessageContext{line: line, source: line.sender, target: target, body: message}

    IO.puts("[" <> target <> "] <" <> line.sender <> "> " <> message)

    with "!" <> remainder <- message do
      handle_command(socket, context, String.split(remainder))
    end
  end

  defp process_line(socket, line) do
    IO.puts("--> " <> String.trim(line.raw))

    case line.command do
      "ERROR" -> exit(1)
      "PING" -> puts!(socket, "PONG " <> hd(line.params))
      "376" -> puts!(socket, "JOIN #chad")
      "PRIVMSG" -> handle_privmsg(socket, line)
      _ -> nil
    end
  end

  defp privmsg(socket, target, message) do
    puts!(socket, "PRIVMSG " <> target <> " :" <> message)
  end

  defp puts!(socket, data) do
    IO.puts("<-- " <> data)

    Socket.Stream.send!(socket, data <> "\r\n")
  end
end
