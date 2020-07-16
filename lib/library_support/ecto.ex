if Code.ensure_loaded?(Ecto.Type) do
  defmodule Massex.Ecto.Type do
    @moduledoc """
    Provides a type for Ecto to store masses with their units. The underlying type
    should be a map, JSONB would be perfect in a PostgreSQL database.

    ## Migration Example

        create table(:foo) do
          add :mass, :jsonb
        end

    ## Schema Example

        schema "foo" do
          field :mass, Massex.Ecto.Type
        end
    """

    if macro_exported?(Ecto.Type, :__using__, 1) do
      use Ecto.Type
    else
      @behaviour Ecto.Type
    end

    @spec type() :: :map
    def type, do: :map

    def embed_as(_), do: :dump

    @spec cast(Massex.t() | {integer(), String.t()} | map() | any()) :: :error | {:ok, Massex.t()}
    def cast(%Massex{} = mass) do
      {:ok, mass}
    end

    def cast({amount, unit})
        when (is_integer(amount) or is_binary(amount)) and (is_binary(unit) or is_atom(unit)) do
      {:ok, Massex.new(amount, unit)}
    end

    def cast({%Decimal{} = amount, unit})
        when is_binary(unit) or is_atom(unit) do
      {:ok, Massex.new(amount, unit)}
    end

    def cast(%{"amount" => amount, "unit" => unit})
        when (is_integer(amount) or is_binary(amount)) and (is_binary(unit) or is_atom(unit)) do
      {:ok, Massex.new(amount, unit)}
    end

    def cast(%{"amount" => %Decimal{} = amount, "unit" => unit})
        when is_binary(unit) or is_atom(unit) do
      {:ok, Massex.new(amount, unit)}
    end

    def cast(%{amount: amount, unit: unit})
        when (is_integer(amount) or is_binary(amount)) and
               (is_binary(unit) or is_atom(unit)) do
      {:ok, Massex.new(amount, unit)}
    end

    def cast(%{amount: %Decimal{} = amount, unit: unit})
        when is_binary(unit) or is_atom(unit) do
      {:ok, Massex.new(amount, unit)}
    end

    def cast(_), do: :error

    @spec dump(any()) :: :error | {:ok, {integer(), String.t()}}
    def dump(%Massex{} = mass) do
      {:ok, %{"amount" => mass.amount, "unit" => to_string(mass.unit)}}
    end

    def dump(_), do: :error

    @spec load(map()) :: {:ok, Massex.t()}
    def load(%{"amount" => amount, "unit" => unit})
        when is_integer(amount) or is_binary(amount) do
      {:ok, Massex.new(amount, String.to_existing_atom(unit))}
    end
  end
end
