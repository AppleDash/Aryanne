defmodule IrcBot.IrcBot do
  use GenServer

  alias IrcBot.Derpibooru
  alias IrcBot.Irc.MessageContext

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
    cmd_ctx = %IrcBot.CommandContext{command: cmd, args: args}

    case IrcBot.CommandHandler.handle_command(CommandHandler, cmd_ctx) do
      {:respond, response} -> privmsg(socket, MessageContext.reply_target(context), response)
      {:nothing} -> nil
    end
  end

  defp handle_heil(socket, context) do
    reply_to = MessageContext.reply_target(context)

    case Derpibooru.random_image("sieg heil") do
      {:ok, image} ->
        privmsg(
          socket,
          reply_to,
          "Sieg heil! https://derpibooru.org/images/" <> Integer.to_string(image["id"])
        )

      err ->
        privmsg(socket, reply_to, ":(")
    end
  end

  defp handle_privmsg(socket, line) do
    [target, message] = line.params

    context = %MessageContext{line: line, source: line.sender, target: target, body: message}

    IO.puts("[" <> target <> "] <" <> line.sender <> "> " <> message)

    case message do
      "!" <> remainder -> handle_command(socket, context, String.split(remainder))
      "heil" -> handle_heil(socket, context)
      _ -> nil
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
