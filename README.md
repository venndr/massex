# Massex

![](https://github.com/venndr/massex/workflows/CI/badge.svg)

Massex is a simple pattern for holding masses and interacting with them in a sensible manner.
It follows the whole value pattern, and allows easy storage, retrieval and mathematics upon
values of mass in disparate scales.

```elixir
iex> one = Massex.new(10, :gram)
...> two = Massex.new(10, :ounce)
...> Massex.add(one, two)
```

All the documentation is on [HexDocs](http://hexdocs.pm/massex)

## Supporting Libraries

Massex ships with Jason support which will automatically be loaded if
your project is using Jason for JSON handling. Additionally, it also
supports Absinthe and Ecto.

### Absinthe

To activate the Absinthe support, just import the types in your schema:

```elixir
import_types Massex.Absinthe.Type
```

You can then use Massex objects in your Schemas

```elixir
object :lorry do
  field :mass, :mass
end
```

Or in your mutations

```elixir
payload field :set_lorry_mass do
  input do
    field :id, non_null(:id)
    field :mass, non_null(:mass_input)
  end
end
```

### Ecto

You can transparently store Massex structs in your schemas by
adding the mass field as a map/json/jsonb type in your schema.

```elixir
schema "lorries" do
  field :mass, Massex.Ecto.Type
end
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

## Licence

ISC License

Copyright (c) 2024 Music Glue

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
PERFORMANCE OF THIS SOFTWARE.

A copy of the licence text is also included in the file LICENSE.

---

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/massex](https://hexdocs.pm/massex).

