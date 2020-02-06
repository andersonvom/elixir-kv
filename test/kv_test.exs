defmodule KVTest do
  use ExUnit.Case
  doctest KV

  test "starts the supervisor" do
    status = :sys.get_status(KV.Supervisor)

    assert status
  end
end
