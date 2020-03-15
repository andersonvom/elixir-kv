defmodule KV.RouterTest do
  use ExUnit.Case, async: true

  @tag :distributed
  test "route requests across nodes" do
    assert route("hello") == :"foo@andersonvom-tw"
    assert route("world") == :"bar@andersonvom-tw"
  end

  test "raises on unknown entries" do
    assert_raise RuntimeError, ~r/could not find entry/, fn ->
      route(<<0>>)
    end
  end

  defp route(input) do
      KV.Router.route(input, Kernel, :node, [])
  end
end
