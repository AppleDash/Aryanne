defmodule IrcBot.IrcBot do
  use GenServer

  alias IrcBot.Derpibooru
  alias IrcBot.Irc.MessageContext

  def init(:ok) do
    {:ok, %{socket: Socket.TCP.connect!("irc.canternet.org", 6667, packet: :line, mode: :active)}}
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def handle_info(msg, %{socket: socket} = state) do
    with {:tcp, ^socket, message} <- msg do
      process_line(socket, Line.parse!(message))
    end

    {:noreply, state}
  end

  def start() do
    sock = Socket.TCP.connect!("irc.canternet.org", 6667, packet: :line, mode: :active)

    puts!(sock, "NICK Aryanne")
    puts!(sock, "USER Aryanne * * :Aryanne")

    loop(sock)
  end

  defp handle_command(socket, context, [cmd | args]) do
    case cmd do
      "ping" -> privmsg(socket, MessageContext.reply_target(context), "Pong!")
      _ -> nil
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

      {:error, _} ->
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

  defp loop(socket) do
    receive do
      {:tcp, ^socket, message} -> process_line(socket, Line.parse!(message))
    end

    loop(socket)
  end
end
