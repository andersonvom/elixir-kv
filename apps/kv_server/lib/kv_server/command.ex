defmodule KVServer.Command do
  @doc ~S"""
  Parses the given `line` into a command.

  ## Examples

      iex> KVServer.Command.parse("CREATE shopping\r\n")
      {:ok, {:create, "shopping"}}

      iex> KVServer.Command.parse("CREATE   shopping   \r\n")
      {:ok, {:create, "shopping"}}

      iex> KVServer.Command.parse("PUT shopping milk 1\r\n")
      {:ok, {:put, "shopping", "milk", "1"}}

      iex> KVServer.Command.parse("GET shopping milk\r\n")
      {:ok, {:get, "shopping", "milk"}}

      iex> KVServer.Command.parse("DELETE shopping eggs\r\n")
      {:ok, {:delete, "shopping", "eggs"}}

  Unknown commands or commands with the wrong number of arguments return an error:

      iex> KVServer.Command.parse("UNKNOWN shopping eggs\r\n")
      {:error, :unknown_command}

      iex> KVServer.Command.parse("GET shopping\r\n")
      {:error, :unknown_command}

  """
  def parse(line) do
    case String.split(line) do
      ["CREATE", bucket] -> {:ok, {:create, bucket}}
      ["DELETE", bucket, item] -> {:ok, {:delete, bucket, item}}
      ["GET", bucket, item] -> {:ok, {:get, bucket, item}}
      ["PUT", bucket, item, amount] -> {:ok, {:put, bucket, item, amount}}
      _ -> {:error, :unknown_command}
    end
  end
end
