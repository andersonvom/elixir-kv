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
    response =
      with {:ok, data} <- read_line(client),
           {:ok, command} <- KVServer.Command.parse(data),
           {:ok, msg} <- KVServer.Command.run(command),
           do: write_line(client, msg)

    case response do
      {:error, :unknown_command} -> write_line(client, "Unknown Command\r\n")
      {:error, error} -> quit(client, error)
      _ -> :ok
    end

    serve(client)
  end

  defp read_line(client) do
    :gen_tcp.recv(client, 0)
  end

  defp write_line(client, text) do
    :gen_tcp.send(client, text)
  end

  defp quit(client, :closed) do
    Logger.info("Client disconnected from #{inspect client}")
    exit(:shutdown)
  end

  defp quit(client, error) do
    Logger.error("Error from client #{inspect client}")
    exit(error)
  end
end
