defmodule Day05Test do
  use ExUnit.Case, async: true

  import Day05

  test "advanced intcode" do
    assert intcode([3,0,4,0,99], [999]) == 999
    assert intcode([3,0,4,0,99], [1337]) == 1337
    assert intcode([1002,4,3,4,33], [1]) == :error
  end

  test "new opcodes" do
    assert intcode([3,9,8,9,10,9,4,9,99,-1,8], [7]) == 0
    assert intcode([3,9,8,9,10,9,4,9,99,-1,8], [8]) == 1
    assert intcode([3,9,7,9,10,9,4,9,99,-1,8], [7]) == 1
    assert intcode([3,9,7,9,10,9,4,9,99,-1,8], [8]) == 0
    assert intcode([3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9], [0]) == 0
    assert intcode([3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9], [5]) == 1
  end

  test "jump and if codes" do
    program = [3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,
               1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,
               999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99]

    assert intcode(program, [7]) == 999
    assert intcode(program, [8]) == 1000
    assert intcode(program, [9]) == 1001
  end

  test "opcode parsing" do
    assert parse_opcode(1101) == {:add, {1, 1, 0}}
    assert parse_opcode(1002) == {:multiply, {0, 1, 0}}
    assert parse_opcode(3) == {:save_input, {0, 0, 0}}
  end
end
