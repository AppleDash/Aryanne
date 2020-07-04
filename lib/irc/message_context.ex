defmodule IrcBot.Irc.MessageContext do
  defstruct line: nil, source: nil, target: nil, body: nil

  @doc """
  Figure out the reply target from a given MessageContext.
  It should be the target if it's a channel, otherwise the sender.

  ## Examples

  iex> MessageContext.reply_target(%MessageContext{source: "Foo", target: "Bar"}})
  "Foo"

  iex> MessageContext.reply_target(%MessageContext{source: "Foo", target: "#bar"}})
  "#bar"
  """
  def reply_target(%{source: source, target: target}) do
    case String.at(target, 0) do
      "#" -> target
      "&" -> target
      _ -> source
    end
  end
end
