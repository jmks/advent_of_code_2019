defmodule Day07Test do
  use ExUnit.Case, async: true

  import Day07

  test "combinations" do
    assert combinations([1,2,3]) == [
      [1,2,3],
      [1,3,2],
      [2,1,3],
      [2,3,1],
      [3,1,2],
      [3,2,1]
    ]
  end

  test "find max amplification" do
    assert max_amplification([3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0], 4) == 43210
    assert max_amplification([3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0], 4) == 54321
    assert max_amplification([3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0], 4) == 65210
  end
end
