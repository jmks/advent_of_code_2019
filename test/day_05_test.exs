defmodule Day05Test do
  use ExUnit.Case, async: true

  import Day05

  test "advanced intcode" do
    assert intcode([3,0,4,0,99], [999]) == 999
    assert intcode([3,0,4,0,99], [1337]) == 1337
    assert intcode([1002,4,3,4,33], [1]) == :error
  end
end
