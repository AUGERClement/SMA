defmodule SmaTest do
  use ExUnit.Case
  doctest Sma

  test "greets the world" do
    assert Sma.hello() == :world
  end
end
