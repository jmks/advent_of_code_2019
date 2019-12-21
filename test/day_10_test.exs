defmodule Day10Test do
  use ExUnit.Case, async: true

  import Day10

  @small_field """
  .#..#
  .....
  #####
  ....#
  ...##
  """

  @medium_field """
  ......#.#.
  #..#.#....
  ..#######.
  .#.#.###..
  .#..#.....
  ..#....#.#
  #..#....#.
  .##.#..###
  ##...#..#.
  .#....####
  """

  @medium2_field """
  #.#...#.#.
  .###....#.
  .#....#...
  ##.#.#.#.#
  ....#.#.#.
  .##..###.#
  ..#...##..
  ..##....##
  ......#...
  .####.###.
  """

  @medium3_field """
  .#..#..###
  ####.###.#
  ....###.#.
  ..###.##.#
  ##.##.#.#.
  ....###..#
  ..#.#..#.#
  #..#.#.###
  .##...##.#
  .....#.#..
  """

  @large_field """
  .#..##.###...#######
  ##.############..##.
  .#.######.########.#
  .###.#######.####.#.
  #####.##.#.##.###.##
  ..#####..#.#########
  ####################
  #.####....###.#.#.##
  ##.#################
  #####.##.###..####..
  ..######..##.#######
  ####.##.####...##..#
  .#####..#.######.###
  ##...#.##########...
  #.##########.#######
  .####.#.###.###.#.##
  ....##.##.###..#####
  .#.#.###########.###
  #.#.#.#####.####.###
  ###.##.####.##.#..##
  """

  @new_field """
  .#....#####...#..
  ##...##.#####..##
  ##...#...#.#####.
  ..#.....#...###..
  ..#.#.....#....##
  """

  test "some math" do
    assert greatest_common_divisor(3, 12) == 3
    assert greatest_common_divisor(3, 3) == 3
    assert greatest_common_divisor(1071, 462) == 21

    assert line_from_origin({1, 1}) == {1, 1}
    assert line_from_origin({3, 3}) == {1, 1}
    assert line_from_origin({3, 4}) == {4, 3}
  end

  test "reading asteroid field" do
    assert read_asteroid_field(@small_field) == [
      {1, 0}, {4, 0},
      {0, 2}, {1, 2}, {2, 2}, {3, 2}, {4, 2},
      {4, 3},
      {3, 4}, {4, 4},
    ]
  end

  test "best observation point" do
    assert best_observation_point(read_asteroid_field(@small_field)) == {{3, 4}, 8}
    assert best_observation_point(read_asteroid_field(@medium_field)) == {{5, 8}, 33}
    assert best_observation_point(read_asteroid_field(@medium2_field)) == {{1, 2}, 35}
    assert best_observation_point(read_asteroid_field(@medium3_field)) == {{6, 3}, 41}
    assert best_observation_point(read_asteroid_field(@large_field)) == {{11, 13}, 210}

    assert best_observation_point(read_asteroid_field(@large_field)) == {{11, 13}, 210}
  end

  test "vaporize order" do
    assert vaporize_order(read_asteroid_field(@new_field), {8, 3}) == [
      {8, 1}, {9, 0}, {9, 1}, {10, 0}, {9, 2}, {11, 1}, {12, 1}, {11, 2}, {15, 1},
      {12, 2}, {13, 2}, {14, 2}, {15, 2}, {12, 3}, {16, 4}, {15, 4}, {10, 4}, {4, 4},
      {2, 4}, {2, 3}, {0, 2}, {1, 2}, {0, 1}, {1, 1}, {5, 2}, {1, 0}, {5, 1},
      {6, 1}, {6, 0}, {7, 0}, {8, 0}, {10, 1}, {14, 0}, {16, 1}, {13, 3},
      {14, 3}
    ]

    big_vaporized = vaporize_order(read_asteroid_field(@large_field), {11,13})
    [{11, 12}, {12, 1}, {12, 2} | _] = big_vaporized
    assert Enum.at(big_vaporized, 199) == {8, 2}
  end
end
