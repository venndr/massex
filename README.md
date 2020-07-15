# Massex

Massex is a simple pattern for holding masses and interacting with them in a sensible manner.
It follows the whole value pattern, and allows easy storage, retrieval and mathematics upon
values of mass in disparate scales.

```elixir
iex> one = Massex.new(10, :gram)
...> two = Massex.new(10, :ounce)
...> Massex.add(one, two)
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `massex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:massex, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/massex](https://hexdocs.pm/massex).

