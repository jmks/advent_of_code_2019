defmodule Day09Test do
  use ExUnit.Case, async: true

  import Day09

  test "existing Intcode_halt programs" do
    assert intcode_halt([3,0,4,0,99], [999]) == 999
    assert intcode_halt([3,0,4,0,99], [1337]) == 1337
    assert intcode_halt([3,9,8,9,10,9,4,9,99,-1,8], [7]) == 0
    assert intcode_halt([3,9,8,9,10,9,4,9,99,-1,8], [8]) == 1
    assert intcode_halt([3,9,7,9,10,9,4,9,99,-1,8], [7]) == 1
    assert intcode_halt([3,9,7,9,10,9,4,9,99,-1,8], [8]) == 0
    assert intcode_halt([3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9], [0]) == 0
    assert intcode_halt([3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9], [5]) == 1

    program = [3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,
               1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,
               999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99]

    assert intcode_halt(program, [7]) == 999
    assert intcode_halt(program, [8]) == 1000
    assert intcode_halt(program, [9]) == 1001
  end
end
