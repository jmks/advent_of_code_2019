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
  end
end
