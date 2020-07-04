defmodule Line do
  @moduledoc """
  IRC line parser.
  """

  # the world's most cancerous regex
  @lineregex ~r/(?<sender>:[^[:space:]]+)?[[:space:]]?(?<command>[^[:space:]]+)[[:space:]]?(?<args>[^:]+)?[[:space:]]?(?<long_arg>:.+)?/

  defstruct sender: nil, command: nil, params: [], raw: nil

  @doc """
  Parses a raw IRC protocol line into its various components.
  Any nonexistent components become nil.

  ## Examples

  iex> Line.parse("")
  {:error}

  iex> Line.parse(":lol.org PRIVMSG")
  {:ok, %Line{sender: "lol.org", command: "PRIVMSG", params: [], raw: ":lol.org PRIVMSG"}}

  iex> Line.parse("PING")
  {:ok, %Line{sender: nil, command: "PING", params: [], raw: "PING"}}

  iex> Line.parse("PING Elizacat")
  {:ok, %Line{sender: nil, command: "PING", params: ["Elizacat"], raw: "PING Elizacat"}}

  iex> Line.parse("PING Elizacat :dongs")
  {:ok, %Line{sender: nil, command: "PING", params: ["Elizacat", "dongs"], raw: "PING Elizacat :dongs"}}

  iex> Line.parse(":dongs!dongs@lol.org PRIVMSG loldongs meow :dongs")
  {:ok, %Line{sender: "dongs!dongs@lol.org", command: "PRIVMSG", params: ["loldongs", "meow", "dongs"], raw: ":dongs!dongs@lol.org PRIVMSG loldongs meow :dongs"}}

  iex> Line.parse(":dongs PRIVMSG #cocks :This is a very long arg.")
  {:ok, %Line{sender: "dongs", command: "PRIVMSG", params: ["#cocks", "This is a very long arg."], raw: ":dongs PRIVMSG #cocks :This is a very long arg."}}
  """
  def parse(raw) do
    case Regex.named_captures(@lineregex, String.trim(raw)) do
      nil -> {:error}
      matches -> {:ok, parse(raw, matches)}
    end
  end

  def parse!(raw) do
    case parse(raw) do
      {:error} -> raise ArgumentError, "Invalid IRC line"
      {:ok, line} -> line
    end
  end

  defp parse(raw, matches) do
    args =
      case matches["long_arg"] do
        "" -> split_args(matches["args"])
        long_arg -> split_args(matches["args"]) ++ [strip_first(long_arg)]
      end

    %Line{
      sender: presence(strip_first(matches["sender"])),
      command: presence(matches["command"]),
      params: args,
      raw: raw
    }
  end

  defp strip_first("") do
    ""
  end

  defp strip_first(str) do
    String.slice(str, 1, String.length(str) - 1)
  end

  defp split_args(args) do
    String.split(args, ~r/[[:space:]]/, trim: true)
  end

  defp presence("") do
    nil
  end

  defp presence(str) do
    str
  end
end
