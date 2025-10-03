defmodule MassexTest do
  use ExUnit.Case
  doctest Massex

  test "holds an amount" do
    assert Massex.new(10, :gram).amount == Decimal.new(10)
  end

  test "holds the unit" do
    assert Massex.new(10, :g).unit == :gram
  end

  test "can be Jason encoded" do
    amount = 10 |> Massex.new(:gram) |> Jason.encode!() |> Jason.decode!()
    assert amount == %{"amount" => "10", "unit" => "gram"}
  end

  test "Massex.abs/1 returns the absolute amount" do
    mass = Massex.new(-10, :gram)
    assert Massex.abs(mass) == Massex.new(10, :gram)
  end

  test "Massex.add/2 adds two values" do
    left = Massex.new(10, :gram)
    right = Massex.new(20, :gram)
    assert Massex.add(left, right) == Massex.new(30, :gram)
  end

  test "Massex.add/2 standardizes to left-most unit" do
    left = Massex.new(10, :gram)
    right = Massex.new(10, :oz)
    assert Massex.add(left, right) == Massex.new("293.4950", :gram)
  end

  test "Massex.add/2 allows adding simple values to an existing Massex" do
    mass = Massex.new(10, :gram)

    assert Massex.add(mass, 10) == Massex.new(20, :gram)
    assert Massex.add(mass, "10") == Massex.new(20, :gram)
    assert Massex.add(mass, 10.0) == Massex.new("20.0", :gram)
    assert Massex.add(mass, Decimal.new(10)) == Massex.new(20, :gram)
  end

  test "Massex.compare/2 compares two `Massex` structs with each other" do
    less = Massex.new(10, :gram)
    more = Massex.new(20, :ounce)

    assert Massex.compare(less, less) == 0
    assert Massex.compare(more, more) == 0
    assert Massex.compare(less, more) == -1
    assert Massex.compare(more, less) == 1
  end

  test "Massex.divide/2 divides a `Massex` by the provided denominator" do
    mass = Massex.new(10, :gram)

    assert Massex.divide(mass, 2) == Massex.new(5, :gram)
  end

  test "Massex.equals?/2 returns true if two masses represent the same amount" do
    left = Massex.new("28.3495", :gram)
    right = Massex.new(1, :ounce)

    assert Massex.equals?(left, right)

    left = Massex.new("453.592", :gram)
    right = Massex.new(1, :pound)

    assert Massex.equals?(left, right)

    left = Massex.new("16", :ounce)
    right = Massex.new(1, :pound)

    assert Massex.equals?(left, right)
  end

  test "Massex.multiply/2 multiplies a Massex by an amount" do
    mass = Massex.new(10, :gram)

    assert Massex.multiply(mass, 10) == Massex.new(100, :gram)
  end

  test "Massex.negative?/1 returns true if the value is negative" do
    negative = Massex.new(-10, :gram)
    positive = Massex.new(10, :gram)

    assert Massex.negative?(negative)
    refute Massex.negative?(positive)
  end

  test "Massex.positive?/1 returns true if the value is positive" do
    negative = Massex.new(-10, :gram)
    positive = Massex.new(10, :gram)

    refute Massex.positive?(negative)
    assert Massex.positive?(positive)
  end

  test "Massex.subtract/2 subtracts one `Massex` from another, or a simple value from a `Massex`" do
    left = Massex.new(40, :gram)
    right = Massex.new(1, :ounce)

    assert Massex.subtract(left, right) == Massex.new("11.6505", :gram)
    assert Massex.subtract(left, 10) == Massex.new(30, :gram)
    assert Massex.subtract(left, "10") == Massex.new(30, :gram)

    left = Massex.new(500, :gram)
    right = Massex.new(1, :pound)

    assert Massex.subtract(left, right) == Massex.new("46.408", :gram)
    assert Massex.subtract(left, 10) == Massex.new(490, :gram)
    assert Massex.subtract(left, "10") == Massex.new(490, :gram)
  end

  test "Massex.to_decimal/2 returns a Decimal representation of the Massex struct" do
    mass = Massex.new(10, :gram)

    assert Massex.to_decimal(mass) == mass.amount
  end

  test "Massex.zero?/1 returns true if the amount of the Massex is zero" do
    zero = Massex.new(0, :gram)
    not_zero = Massex.new("0.0001", :gram)

    assert Massex.zero?(zero)
    refute Massex.zero?(not_zero)
  end
end
