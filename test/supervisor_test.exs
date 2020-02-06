defmodule KV.SupervisorTest do
  use ExUnit.Case, async: true

  setup do
    {_, pid, _, _} = :sys.get_status(KV.Supervisor)
    %{sup: pid}
  end

  test "should start children", %{sup: sup} do
    [{name, pid, _, _}] = Supervisor.which_children(sup)

    assert is_pid(pid)
    assert name == KV.Registry
  end
end
