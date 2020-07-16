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
  @spec add(t(), t() | number() | String.t()) :: t() | {:error, :invalid_amount}
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

  @doc """
  Divides a `Massex` by the provided denominator

  ## Examples

      iex> base = Massex.new(10, :gram)
      iex> Massex.divide(base, 2)
      %Massex{amount: Decimal.new(5), unit: :gram}
  """
  @spec divide(t(), number()) :: t()
  def divide(%__MODULE__{amount: amount, unit: unit}, denominator),
    do: %__MODULE__{amount: Decimal.div(amount, denominator), unit: unit}

  @doc """
  Returns true if two `Massex` represent the same amount of mass

  ## Examples

      iex> left = Massex.new(10, :gram)
      iex> right = Massex.new(10, :gram)
      iex> Massex.equals?(left, right)
      true
  """
  @spec equals?(t(), t()) :: boolean()
  def equals?(%__MODULE__{amount: left, unit: unit}, %__MODULE__{amount: right, unit: unit}),
    do: Decimal.eq?(left, right)

  def equals?(%__MODULE__{amount: left, unit: leftunit}, %__MODULE__{
        amount: right,
        unit: rightunit
      }),
      do: right |> convert_amount(rightunit, leftunit) |> Decimal.eq?(left)

  @doc """
  Multiplies a `Massex` by the provided amount

  ## Examples

      iex> mass = Massex.new(10, :gram)
      iex> Massex.multiply(mass, 10)
      %Massex{amount: Decimal.new(100), unit: :gram}
  """
  @spec multiply(t(), number()) :: t()
  def multiply(%__MODULE__{amount: amount, unit: unit}, value),
    do: %__MODULE__{amount: Decimal.mult(amount, value), unit: unit}

  @doc """
  Returns true if the amount of a `Massex` is less than zero

  ## Examples

      iex> Massex.negative?(Massex.new(-10, :gram))
      true
      iex> Massex.negative?(Massex.new(10, :gram))
      false
  """
  @spec negative?(t()) :: boolean()
  def negative?(%__MODULE__{amount: amount}), do: Decimal.negative?(amount)

  @doc """
  Returns true if the amount of a `Massex` is more than zero

  ## Examples

      iex> Massex.positive?(Massex.new(-10, :gram))
      false
      iex> Massex.positive?(Massex.new(10, :gram))
      true
  """
  @spec positive?(t()) :: boolean()
  def positive?(%__MODULE__{amount: amount}), do: Decimal.positive?(amount)

  @doc """
  Subtracts one Massex struct from another, returning a Massex

  ## Examples

      iex> left = Massex.new(20, :gram)
      iex> right = Massex.new(10, :gram)
      iex> Massex.subtract(left, right)
      %Massex{unit: :gram, amount: Decimal.new(10)}
      iex> Massex.subtract(left, 10)
      %Massex{unit: :gram, amount: Decimal.new(10)}
  """
  @spec subtract(t(), t() | number() | String.t()) :: t() | {:error, :invalid_amount}
  def subtract(%__MODULE__{amount: leftval, unit: unit}, %__MODULE__{amount: rightval, unit: unit}),
      do: %__MODULE__{amount: Decimal.sub(leftval, rightval), unit: unit}

  def subtract(%__MODULE__{amount: leftval, unit: leftunit}, %__MODULE__{
        amount: rightval,
        unit: rightunit
      }),
      do: %__MODULE__{
        amount: Decimal.sub(leftval, convert_amount(rightval, rightunit, leftunit)),
        unit: leftunit
      }

  def subtract(%__MODULE__{amount: amount, unit: unit}, value) do
    case cast_amount(value) do
      :error -> {:error, :invalid_value}
      val -> %__MODULE__{amount: Decimal.sub(amount, val), unit: unit}
    end
  end

  @doc """
  Returns the `Decimal` amount backing the `Massex`

  ## Examples

      iex> mass = Massex.new(20, :gram)
      iex> Massex.to_decimal(mass)
      Decimal.new(20)
  """
  @spec to_decimal(t()) :: Decimal.t()
  def to_decimal(%__MODULE__{amount: amount}), do: amount

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
