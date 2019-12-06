defmodule Day03Test do
  use ExUnit.Case, async: true

  import Day03

  test "parsing paths" do
    assert wire_path("R75,D30,R83,U83,L12,D49,R71,U7,L72") == [
      {:x, 75},
      {:y, -30},
      {:x, 83},
      {:y, 83},
      {:x, -12},
      {:y, -49},
      {:x, 71},
      {:y, 7},
      {:x, -72}
    ]
  end

  test "points" do
    assert points([]) == []
    assert points([x: -2]) == [{-1, 0}, {-2, 0}]
    assert points([x: -2, y: 3, x: 4, y: -5]) == [
      {-1, 0}, {-2, 0},
      {-2, 1}, {-2, 2}, {-2, 3},
      {-1, 3}, {0, 3}, {1, 3}, {2, 3},
      {2, 2}, {2, 1}, {2, 0}, {2, -1}, {2, -2}
    ]
  end

  test "closest intersection" do
    assert closest_intersection("R8,U5,L5,D3", "U7,R6,D4,L4") == 6
    assert closest_intersection("R75,D30,R83,U83,L12,D49,R71,U7,L72", "U62,R66,U55,R34,D71,R55,D58,R83") == 159
    assert closest_intersection("R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51", "U98,R91,D20,R16,D67,R40,U7,R15,U6,R7") == 135
  end

  test "minimum signal delay" do
    assert minimum_signal_delay("R8,U5,L5,D3", "U7,R6,D4,L4") == 30
    assert minimum_signal_delay("R75,D30,R83,U83,L12,D49,R71,U7,L72", "U62,R66,U55,R34,D71,R55,D58,R83") == 610
    assert minimum_signal_delay("R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51", "U98,R91,D20,R16,D67,R40,U7,R15,U6,R7") == 410
  end
end
