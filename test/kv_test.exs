defmodule KVTest do
  use ExUnit.Case
  doctest KV

  test "starts the supervisor" do
    children = Supervisor.which_children(KV.Supervisor)

    assert length(children) == 1
  end
end
