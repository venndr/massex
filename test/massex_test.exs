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
    amount = 10 |> Massex.new(:gram) |> Jason.encode!()
    assert amount == ~s({"amount":"10","unit":"gram"})
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
end
