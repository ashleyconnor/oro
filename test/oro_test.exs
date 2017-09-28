defmodule OroTest do
  use ExUnit.Case
  doctest Oro

  test "greets the world" do
    assert Oro.hello() == :world
  end
end
