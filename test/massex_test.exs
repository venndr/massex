defmodule MassexTest do
  use ExUnit.Case
  doctest Massex

  test "holds a value" do
    assert Massex.new(10, :gram).value == Decimal.new(10)
  end

  test "holds units" do
    assert Massex.new(10, :g).unit == :gram
  end

  test "can be Jason encoded" do
    value = 10 |> Massex.new(:gram) |> Jason.encode!()
    assert value == ~s({"unit":"gram","value":"10"})
  end

  test "can be added" do
    left = Massex.new(10, :gram)
    right = Massex.new(20, :gram)
    assert Massex.add(left, right) == Massex.new(30, :gram)
  end

  test "differing units standardize to left-most unit" do
    left = Massex.new(10, :gram)
    right = Massex.new(10, :oz)
    assert Massex.add(left, right) == Massex.new("293.4950", :gram)
  end
end
