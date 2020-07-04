defmodule IrcBot.Application do
	use Application

	def start(_type, _args) do
		IO.puts "Hi"
		IrcBot.Supervisor.start_link(%{})
	end
end