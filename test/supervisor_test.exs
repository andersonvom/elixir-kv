defmodule KV.SupervisorTest do
  use ExUnit.Case, async: true

  setup do
    {_, pid, _, _} = :sys.get_status(KV.Supervisor)
    %{sup: pid}
  end

  test "should start children", %{sup: sup} do
    children = Supervisor.which_children(sup)

    names = Enum.map(children, fn {name, _, _, _} -> name end)
    assert Enum.member?(names, KV.Registry)
    assert Enum.member?(names, KV.BucketSupervisor)
  end
end
