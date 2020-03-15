defmodule KVServerIntegrationTest do
  use ExUnit.Case
  @moduletag :capture_log

  setup do
    Application.stop(:kv)
    :ok = Application.start(:kv)
  end

  setup do
    opts = [:binary, packet: :line, active: false]
    {:ok, socket} = :gen_tcp.connect('localhost', 4040, opts)
    %{socket: socket}
  end

  @tag :distributed
  test "server interaction", %{socket: socket} do
    assert send_and_recv(socket, "UNKNOWN shopping") == "UNKNOWN COMMAND\r\n"
    assert send_and_recv(socket, "GET shopping eggs") == "NOT FOUND\r\n"
    assert send_and_recv(socket, "CREATE shopping") == "OK\r\n"
    assert send_and_recv(socket, "PUT shopping eggs 3") == "OK\r\n"

    # GET returns two lines
    assert send_and_recv(socket, "GET shopping eggs") == "3\r\n"
    assert recv(socket) == "OK\r\n"

    assert send_and_recv(socket, "DELETE shopping eggs") == "OK\r\n"

    # GET returns two lines
    assert send_and_recv(socket, "GET shopping eggs") == "\r\n"
    assert recv(socket) == "OK\r\n"
  end

  defp recv(socket) do
    {:ok, data} = :gen_tcp.recv(socket, 0, 1000)
    data
  end

  defp send_and_recv(socket, cmd) do
    :ok = :gen_tcp.send(socket, "#{cmd}\r\n")
    recv(socket)
  end
end
