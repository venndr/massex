defmodule Massex do
  @moduledoc """
  Documentation for `Massex`.
  """

  @valid_units ~w[g gram oz ounce]a
  @gram_to_ounce_rate Decimal.from_float(28.3495)

  @derive Jason.Encoder
  @enforce_keys [:unit, :amount]
  defstruct [:unit, :amount]

  @type t :: %__MODULE__{
          unit: atom(),
          amount: Decimal.t()
        }

  @doc """
  Builds a Massex struct from an amount and unit

  ## Examples

      iex> Massex.new(10, :gram)
      %Massex{amount: Decimal.new(10), unit: :gram}
  """
  @spec new(number() | Decimal.t() | String.t(), atom()) ::
          t() | {:error, :invalid_amount}
  def new(amount, unit) when unit in @valid_units do
    case cast_amount(amount) do
      :error -> {:error, :invalid_amount}
      val -> %__MODULE__{unit: standardize_unit(unit), amount: val}
    end
  end

  @doc """
  Returns a `Massex` with the arithmetical absolute of the amount
  """
  @spec abs(t()) :: t()
  def abs(%__MODULE__{amount: amount, unit: unit}),
    do: %__MODULE__{amount: Decimal.abs(amount), unit: unit}

  @doc """
  Adds two Massex structs together, returning a Massex

  ## Examples

      iex> left = Massex.new(10, :gram)
      iex> right = Massex.new(20, :gram)
      iex> Massex.add(left, right)
      %Massex{unit: :gram, amount: Decimal.new(30)}
  """
  @spec add(t(), t()) :: t() | {:error, :invalid_amount}
  def add(%__MODULE__{amount: leftval, unit: unit}, %__MODULE__{amount: rightval, unit: unit}),
    do: %__MODULE__{amount: Decimal.add(leftval, rightval), unit: unit}

  def add(%__MODULE__{amount: leftval, unit: leftunit}, %__MODULE__{
        amount: rightval,
        unit: rightunit
      }),
      do: %__MODULE__{
        amount: Decimal.add(leftval, convert_amount(rightval, rightunit, leftunit)),
        unit: leftunit
      }

  def add(%__MODULE__{amount: amount, unit: unit}, value) do
    case cast_amount(value) do
      :error -> {:error, :invalid_value}
      val -> %__MODULE__{amount: Decimal.add(amount, val), unit: unit}
    end
  end

  @doc """
  Compares two Massex structs, returning 0 on equality, 1 if left is greater than right, or -1 if left is less than right

  ## Examples

      iex> less = Massex.new(10, :gram)
      iex> more = Massex.new(20, :gram)
      iex> Massex.compare(less, less)
      0
      iex> Massex.compare(less, more)
      -1
      iex> Massex.compare(more, less)
      1
  """
  @spec compare(t(), t()) :: integer()
  def compare(%__MODULE__{amount: leftval, unit: unit}, %__MODULE__{amount: rightval, unit: unit}),
    do: leftval |> Decimal.compare(rightval) |> Decimal.to_integer()

  def compare(%__MODULE__{amount: leftval, unit: leftunit}, %__MODULE__{
        amount: rightval,
        unit: rightunit
      }),
      do:
        with(
          newval <- convert_amount(rightval, rightunit, leftunit),
          do: leftval |> Decimal.compare(newval) |> Decimal.to_integer()
        )

  defp standardize_unit(:g), do: :gram
  defp standardize_unit(:oz), do: :ounce
  defp standardize_unit(unit), do: unit

  defp cast_amount(%Decimal{} = amount), do: amount
  defp cast_amount(amount) when is_float(amount), do: Decimal.from_float(amount)
  defp cast_amount(amount) when is_number(amount), do: Decimal.new(amount)

  defp cast_amount(amount) when is_binary(amount),
    do: with({:ok, val} <- Decimal.parse(amount), do: val)

  defp convert_amount(amount, :gram, :ounce), do: Decimal.div(amount, @gram_to_ounce_rate)
  defp convert_amount(amount, :ounce, :gram), do: Decimal.mult(amount, @gram_to_ounce_rate)
end
