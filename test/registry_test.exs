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

  test "removes buckets on exit", %{registry: registry} do
    KV.Registry.create(registry, @bucket_name)
    {:ok, bucket} = KV.Registry.lookup(registry, @bucket_name)

    Agent.stop(bucket)

    assert KV.Registry.lookup(registry, @bucket_name) == :error
  end

  test "removes bucket on crash", %{registry: registry} do
    KV.Registry.create(registry, @bucket_name)
    {:ok, bucket} = KV.Registry.lookup(registry, @bucket_name)

    # Stop the bucket with non-normal reason
    Agent.stop(bucket, :shutdown)

    assert KV.Registry.lookup(registry, @bucket_name) == :error
  end
end
