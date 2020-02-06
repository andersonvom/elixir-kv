# KV

A simple key-value store to learn elixir concepts.

## Dependencies

```bash
brew install elixir
```

## Development

```bash
# run all tests once
mix test

# watch for code changes
brew install fswatch
fswatch lib test -o | xargs -n1 -I{} mix test
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `kv` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:kv, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/kv](https://hexdocs.pm/kv).

