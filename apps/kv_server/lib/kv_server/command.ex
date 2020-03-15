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

  @doc """
  Runs the given command.
  """
  def run(command)

  def run({:create, bucket}) do
    KV.Registry.create(KV.Registry, bucket)
    ok()
  end

  def run({:get, bucket, key}) do
    lookup(bucket, fn pid ->
      value = KV.Bucket.get(pid, key)
      ok(value)
    end)
  end

  def run({:put, bucket, key, value}) do
    lookup(bucket, fn pid ->
      KV.Bucket.put(pid, key, value)
      ok()
    end)
  end

  def run({:delete, bucket, key}) do
    lookup(bucket, fn pid ->
      KV.Bucket.delete(pid, key)
      ok()
    end)
  end

  defp lookup(bucket, callback) do
    route = KV.Router.route(bucket, KV.Registry, :lookup, [KV.Registry, bucket])

    case route do
      {:ok, pid} -> callback.(pid)
      :error -> {:error, :not_found}
    end
  end

  defp ok() do
    {:ok, "OK\r\n"}
  end

  defp ok(value) do
    {:ok, "#{value}\r\nOK\r\n"}
  end
end
