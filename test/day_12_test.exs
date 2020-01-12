defmodule Day12Test do
  use ExUnit.Case, async: true

  import Day12

  @example_positions [
    {-1, 0, 2},
    {2, -10, -7},
    {4, -8, 8},
    {3, 5, -1}
  ]

  test "gravity" do
    assert gravity({3, 5, 4}, {5, 3, 4}) == {1, -1, 0}
    assert gravity({5, 3, 4}, {3, 5, 4}) == {-1, 1, 0}
  end

  test "all_pairs" do
    assert all_pairs([]) == []
    assert all_pairs([1, 2]) == [{1, 2}, {2, 1}]
    assert all_pairs([1, 2, 3]) == [{1, 2}, {1, 3}, {2, 1}, {2, 3}, {3, 1}, {3, 2}]
  end

  test "applying velocity" do
    assert apply_velocity({1, 2, 3}, {-2, 0, 3}) == {-1, 2, 6}
  end

  test "step" do
    step_1 = step(with_velocity(@example_positions))
    assert {{2, -1, 1}, {3, -1, -1}} in step_1
    assert {{3, -7, -4}, {1, 3, 3}} in step_1
    assert {{1, -7, 5}, {-3, 1, -3}} in step_1
    assert {{2, 2, 0}, {-1, -3, 1}} in step_1

    step_10 = steps(with_velocity(@example_positions), 10)
    assert {{2, 1, -3}, {-3, -2, 1}} in step_10
    assert {{1, -8, 0}, {-1, 1, 3}} in step_10
    assert {{3, -6, 1}, {3, 2, -3}} in step_10
    assert {{2, 0, 4}, {1, -1, -1}} in step_10
    assert Enum.sum(Enum.map(step_10, &energy/1)) == 179
  end

  test "repeated state" do
    assert repeated_state(with_velocity(@example_positions)) == 2772
  end
end
