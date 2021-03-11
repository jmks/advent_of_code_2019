defmodule AdventOfCode2019Test do
  use ExUnit.Case, async: true

  import Day01

  test "fuel calculations" do
    assert fuel_for_module(2) == 0
    assert fuel_for_module(6) == 0
    assert fuel_for_module(7) == 0
    assert fuel_for_module(12) == 2
    assert fuel_for_module(14) == 2
    assert fuel_for_module(1969) == 654 + 216 + 70 + 21 + 5
    assert fuel_for_module(100_756) == 33583 + 11192 + 3728 + 1240 + 411 + 135 + 43 + 12 + 2
  end
end
