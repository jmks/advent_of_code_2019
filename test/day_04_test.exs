defmodule Day04Test do
  use ExUnit.Case, async: true

  import Day04

  test "valid passwords" do
    assert valid?(111_111)
    refute valid?(223_450)
    refute valid?(123_789)
  end

  test "stricter, but valid passwords" do
    assert stricter_valid?(112_233)
    refute stricter_valid?(123_444)
    assert stricter_valid?(111_122)
  end
end
