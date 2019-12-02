defmodule Day02Test do
  use ExUnit.Case, async: true

  import Day02

  test "intcode processing" do
    code = "1,9,10,3,2,3,11,0,99,30,40,50"

    codes = String.split(code, ",") |> Enum.map(fn x ->
      {int, ""} = Integer.parse(x)
      int
    end)

    assert intcode(codes) == [
      3500, 9, 10, 70,
      2,3,11,0,
      99,
      30,40,50
    ]

    assert intcode([1,0,0,0,99]) == [2,0,0,0,99]
    assert intcode([2,3,0,3,99]) == [2,3,0,6,99]
    assert intcode([2,4,4,5,99,0]) == [2,4,4,5,99,9801]
    assert intcode([1,1,1,4,99,5,6,0,99]) == [30,1,1,4,2,5,6,0,99]
  end
end
