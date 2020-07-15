defmodule Massex do
  @moduledoc """
  Documentation for `Massex`.
  """

  @valid_units ~w[g gram oz ounce]a
  @gram_to_ounce_rate Decimal.from_float(28.3495)

  @derive Jason.Encoder
  @enforce_keys [:unit, :value]
  defstruct [:unit, :value]

  @type t :: %__MODULE__{
    unit: atom(),
    value: Decimal.t(),
  }

  @doc """
  Builds a Massex struct from a value and unit

  ## Examples

      iex> Massex.new(10, :gram)
      %Massex{value: Decimal.new(10), unit: :gram}
  """
  @spec new(number() | Decimal.t() | String.t(), atom()) :: __MODULE__.t() | {:error, :invalid_value}
  def new(value, unit) when unit in @valid_units do
    case cast_value(value) do
      :error -> {:error, :invalid_value}
      val -> %__MODULE__{unit: standardize_unit(unit), value: val}
    end
  end

  @doc """
  Adds two Massex structs together, returning a Massex

  ## Examples

      iex> left = Massex.new(10, :gram)
      ...> right = Massex.new(20, :gram)
      ...> Massex.add(left, right)
      %Massex{unit: :gram, value: Decimal.new(30)}
  """
  @spec add(Massex.t(), Massex.t()) :: Massex.t()
  def add(%__MODULE__{value: leftval, unit: unit}, %__MODULE__{value: rightval, unit: unit}), do:
    %__MODULE__{value: Decimal.add(leftval, rightval), unit: unit}

  def add(%__MODULE__{value: leftval, unit: leftunit}, %__MODULE__{value: rightval, unit: rightunit}), do:
    %__MODULE__{
      value: Decimal.add(leftval, convert_value(rightval, rightunit, leftunit)),
      unit: leftunit,
    }

  defp standardize_unit(:g), do: :gram
  defp standardize_unit(:oz), do: :ounce
  defp standardize_unit(unit), do: unit

  defp cast_value(%Decimal{}=value), do: value
  defp cast_value(value) when is_float(value), do: Decimal.from_float(value)
  defp cast_value(value) when is_number(value), do: Decimal.new(value)
  defp cast_value(value) when is_binary(value), do:
    with({:ok, val} <- Decimal.parse(value), do: val)

  defp convert_value(value, :gram, :ounce), do: Decimal.div(value, @gram_to_ounce_rate)
  defp convert_value(value, :ounce, :gram), do: Decimal.mult(value, @gram_to_ounce_rate)
end
