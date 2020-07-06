defmodule IrcBot.Application do
  use Application

  def start(_type, _args) do
    IrcBot.Supervisor.start_link(%{host: "irc.canternet.org", port: 6667, nick: "Aryanne"})

    loop()
  end

  def loop() do
    loop()
  end
end
