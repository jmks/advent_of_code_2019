defmodule Day04Test do
  use ExUnit.Case, async: true

  import Day04

  test "valid passwords" do
    assert valid?(111111)
    refute valid?(223450)
    refute valid?(123789)
  end

  test "stricter, but valid passwords" do
    assert stricter_valid?(112233)
    refute stricter_valid?(123444)
    assert stricter_valid?(111122)
  end
end
