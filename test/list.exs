defmodule ConsTheMagnificentAlternateTest do
  use ExUnit.Case

  import Lix.ListMutable

  test "multirember" do
    assert [:coffee, :tea, :and, :hick] ==
             multirember(:cup, [:coffee, :cup, :tea, :cup, :and, :hick, :cup])
  end

  test "multiinsertR" do
    assert [:a, :y, :x, :b, :y, :x] == multiinsertR(:x, :y, [:a, :y, :b, :y])
  end

  test "multiinsertL" do
    assert [:a, :x, :y, :b, :x, :y] == multiinsertL(:x, :y, [:a, :y, :b, :y])
  end

  test "mutlisubst" do
    assert [:my, :other, :foo, :is, :a, :foo] ==
             multisubst(:foo, :bar, [:my, :other, :bar, :is, :a, :bar])
  end
end
