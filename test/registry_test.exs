defmodule KV.RegistryTest do
  use ExUnit.Case, async: true

  @bucket_name "shopping"

  setup do
    registry = start_supervised!(KV.Registry)
    %{registry: registry}
  end

  test "spawns buckets", %{registry: registry} do
    assert KV.Registry.lookup(registry, @bucket_name) == :error

    KV.Registry.create(registry, @bucket_name)

    assert {:ok, bucket} = KV.Registry.lookup(registry, @bucket_name)
  end
end