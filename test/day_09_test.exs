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

  test "additional cases (from day 5!)" do
    assert intcode_output_after_halt([109, -1, 4, 1, 99], []) == [-1]
    assert intcode_output_after_halt([109, -1, 104, 1, 99], []) == [1]
    assert intcode_output_after_halt([109, -1, 204, 1, 99], []) == [109]
    assert intcode_output_after_halt([109, 1, 9, 2, 204, -6, 99], []) == [204]
    assert intcode_output_after_halt([109, 1, 109, 9, 204, -6, 99], []) == [204]
    assert intcode_output_after_halt([109, 1, 209, -1, 204, -106, 99], []) == [204]
    assert intcode_output_after_halt([109, 1, 3, 3, 204, 2, 99], [1337]) == [1337]
    assert intcode_output_after_halt([109, 1, 203, 2, 204, 2, 99], [1337]) == [1337]
  end

  test "new features" do
    assert intcode_output_after_halt([104,1125899906842624,99], []) == [1125899906842624]

    [sixteen_digit_number] = intcode_output_after_halt([1102,34915192,34915192,7,4,7,99,0], [])
    assert length(Integer.digits(sixteen_digit_number)) == 16

    quine = [109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99]
    assert intcode_output_after_halt(quine, []) == quine

    assert intcode_output_after_halt(AdventOfCode2019.read_line_of_cs_ints("09"), [1]) == [3429606717]
  end
end
