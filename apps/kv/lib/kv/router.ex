defmodule KV.Router do
  @doc """
  Dispatch the given `mod`, `fun`, `args` request
  to the appropriate node based on the `bucket`.
  """
  def route(bucket, mod, fun, args) do
    hash(bucket)
    |> get_node(bucket)
    |> run_on_node(bucket, mod, fun, args)
  end

  defp hash(bucket) do
    :binary.first(bucket)
  end

  defp get_node(key, bucket) do
    node = Enum.find(table(), fn {enum, _node} -> key in enum end)
    node || no_entry_error(bucket)
  end

  defp no_entry_error(bucket) do
    raise "could not find entry for #{inspect bucket} in table #{inspect table()}"
  end

  defp run_on_node(node, bucket, mod, fun, args) do
    if elem(node, 1) == node() do
      apply(mod, fun, args)
    else
      {KV.RouterTasks, elem(node, 1)}
      |> Task.Supervisor.async(KV.Router, :route, [bucket, mod, fun, args])
      |> Task.await()
    end
  end

  @doc """
  The routing table.
  """
  def table do
    [
      {?a..?m, :"foo@andersonvom-tw"},
      {?n..?z, :"bar@andersonvom-tw"},
    ]
  end
end

