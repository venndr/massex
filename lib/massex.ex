defmodule Massex do
  @moduledoc """
  Defines a whole value pattern container for masses, and utility methods for
  working with them to improve handling within your applications.
  """

  @pound_to_gram_rate Decimal.from_float(453.592)
  @ounce_to_gram_rate Decimal.from_float(28.3495)
  @zero Decimal.new(0)

  @enforce_keys [:unit, :amount]
  defstruct [:unit, :amount]

  @type t :: %__MODULE__{
          unit: atom(),
          amount: Decimal.t()
        }

  @doc """
  Builds a `Massex` struct from an amount and unit

  ## Examples

      iex> Massex.new(10, :gram)
      %Massex{amount: Decimal.new(10), unit: :gram}
  """
  @spec new(number() | Decimal.t() | String.t(), atom() | String.t()) ::
          t() | :error
  def new(amount, unit) do
    with {:ok, standardized} <- standardize_unit(unit) do
      case cast_amount(amount) do
        :error -> :error
        val -> %__MODULE__{unit: standardized, amount: val}
      end
    end
  end

  @doc """
  Returns a `Massex` with the arithmetical absolute of the amount
  """
  @spec abs(t()) :: t()
  def abs(%__MODULE__{amount: amount, unit: unit}),
    do: %__MODULE__{amount: Decimal.abs(amount), unit: unit}

  @doc """
  Adds two `Massex` structs together, returning a Massex

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
  Compares two `Massex` structs, returning 0 on equality, 1 if left is greater than right, or -1 if left is less than right

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
  def compare(%__MODULE__{amount: leftval, unit: unit}, %__MODULE__{amount: rightval, unit: unit}) do
    leftval
    |> Decimal.compare(rightval)
    |> cmp_to_integer()
  end

  def compare(%__MODULE__{amount: leftval, unit: leftunit}, %__MODULE__{
        amount: rightval,
        unit: rightunit
      }),
      do:
        with(
          newval <- convert_amount(rightval, rightunit, leftunit),
          do:
            leftval
            |> Decimal.compare(newval)
            |> cmp_to_integer()
        )

  defp cmp_to_integer(:eq), do: 0
  defp cmp_to_integer(:gt), do: 1
  defp cmp_to_integer(:lt), do: -1

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

  @doc """
  Returns true if the amount of a `Massex` is zero

  ## Examples

      iex> Massex.zero?(Massex.new(-10, :gram))
      false
      iex> Massex.zero?(Massex.new(0, :gram))
      true
  """
  @spec zero?(t()) :: boolean()
  def zero?(%__MODULE__{amount: amount}), do: Decimal.eq?(amount, @zero)

  defp standardize_unit(:g), do: {:ok, :gram}
  defp standardize_unit(:oz), do: {:ok, :ounce}
  defp standardize_unit(:lb), do: {:ok, :pound}
  defp standardize_unit(:gram), do: {:ok, :gram}
  defp standardize_unit(:ounce), do: {:ok, :ounce}
  defp standardize_unit(:pound), do: {:ok, :pound}

  defp standardize_unit(unit) when is_binary(unit),
    do: unit |> String.to_atom() |> standardize_unit()

  defp standardize_unit(_), do: :error

  defp cast_amount(%Decimal{} = amount), do: amount
  defp cast_amount(amount) when is_float(amount), do: Decimal.from_float(amount)
  defp cast_amount(amount) when is_number(amount), do: Decimal.new(amount)

  defp cast_amount(amount) when is_binary(amount),
    do: with({val, _} <- Decimal.parse(amount), do: val)

  defp convert_amount(amount, :gram, :ounce), do: Decimal.div(amount, @ounce_to_gram_rate)
  defp convert_amount(amount, :ounce, :gram), do: Decimal.mult(amount, @ounce_to_gram_rate)

  defp convert_amount(amount, :gram, :pound), do: Decimal.div(amount, @pound_to_gram_rate)
  defp convert_amount(amount, :pound, :gram), do: Decimal.mult(amount, @pound_to_gram_rate)

  defp convert_amount(amount, :ounce, :pound),
    do: amount |> convert_amount(:ounce, :gram) |> convert_amount(:gram, :pound)

  defp convert_amount(amount, :pound, :ounce),
    do: amount |> convert_amount(:pound, :gram) |> convert_amount(:gram, :ounce)
end
