defmodule KVServer do
  require Logger

  def accept(port) do
    # The options below mean:
    #
    # 1. `:binary` - receives data as binaries (instead of lists)
    # 2. `packet: :line` - receives data line by line
    # 3. `active: false` - blocks on `:gen_tcp.recv/2` until data is available
    # 4. `reuseaddr: true` - allows us to reuse the address if the listener crashes

    opts = [:binary, packet: :line, active: false, reuseaddr: true]
    {:ok, socket} = :gen_tcp.listen(port, opts)
    Logger.info("Accepting connections on port #{port}")
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    Logger.info("Client connected on #{inspect client}")
    serve_async(client)
    loop_acceptor(socket)
  end

  defp serve_async(client) do
    task = fn -> serve(client) end
    {:ok, pid} = Task.Supervisor.start_child(KVServer.TaskSupervisor, task)
    :ok = :gen_tcp.controlling_process(client, pid)
  end

  defp serve(client) do
    client
    |> read_line()
    |> write_line(client)

    serve(client)
  end

  defp read_line(client) do
    {:ok, data} = :gen_tcp.recv(client, 0)
    data
  end

  defp write_line(line, client) do
    :gen_tcp.send(client, line)
  end
end
