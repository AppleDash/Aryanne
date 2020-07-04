defmodule IrcBot.CLI do
  alias IrcBot.Derpibooru

  def main(_args \\ []) do
    sock = Socket.TCP.connect!("irc.canternet.org", 6667, packet: :line, mode: :active)
    
    puts!(sock, "NICK Aryanne")
    puts!(sock, "USER Aryanne * * :Aryanne")

    loop(sock)
  end

  defp handle_command(socket, line, [cmd | args]) do
    case cmd do
      "ping" -> puts!(socket, "PRIVMSG " <> hd(line.params) <> " :Pong!")
      _ -> nil
    end
  end

  defp handle_privmsg(socket, line) do
    [target, message] = line.params

    IO.puts("[" <> target <> "] <" <> line.sender <> "> " <> message)

    case message do
      "!" <> remainder -> handle_command(socket, line, String.split(remainder))
      "heil" -> puts!(socket, "PRIVMSG " <> target <> " :Sieg heil!")
      _ -> nil
    end
  end

  defp process_line(socket, line) do
    IO.puts("--> " <> String.trim(line.raw))

    case line.command do
      "PING" -> puts!(socket, "PONG " <> hd(line.params))
      "376" -> puts!(socket, "JOIN #chad")
      "PRIVMSG" -> handle_privmsg(socket, line)
      _ -> nil
    end
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
