defmodule Day10 do
  @moduledoc """
--- Day 10: Monitoring Station ---

You fly into the asteroid belt and reach the Ceres monitoring station. The Elves here have an emergency: they're having trouble tracking all of the asteroids and can't be sure they're safe.

The Elves would like to build a new monitoring station in a nearby area of space; they hand you a map of all of the asteroids in that region (your puzzle input).

The map indicates whether each position is empty (.) or contains an asteroid (#). The asteroids are much smaller than they appear on the map, and every asteroid is exactly in the center of its marked position. The asteroids can be described with X,Y coordinates where X is the distance from the left edge and Y is the distance from the top edge (so the top-left corner is 0,0 and the position immediately to its right is 1,0).

Your job is to figure out which asteroid would be the best place to build a new monitoring station. A monitoring station can detect any asteroid to which it has direct line of sight - that is, there cannot be another asteroid exactly between them. This line of sight can be at any angle, not just lines aligned to the grid or diagonally. The best location is the asteroid that can detect the largest number of other asteroids.

For example, consider the following map:

.#..#
.....
#####
....#
...##
The best location for a new monitoring station on this map is the highlighted asteroid at 3,4 because it can detect 8 asteroids, more than any other location. (The only asteroid it cannot detect is the one at 1,0; its view of this asteroid is blocked by the asteroid at 2,2.) All other asteroids are worse locations; they can detect 7 or fewer other asteroids. Here is the number of other asteroids a monitoring station on each asteroid could detect:

.7..7
.....
67775
....7
...87
Here is an asteroid (#) and some examples of the ways its line of sight might be blocked. If there were another asteroid at the location of a capital letter, the locations marked with the corresponding lowercase letter would be blocked and could not be detected:

#.........
...A......
...B..a...
.EDCG....a
..F.c.b...
.....c....
..efd.c.gb
.......c..
....f...c.
...e..d..c
Here are some larger examples:

Best is 5,8 with 33 other asteroids detected:

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
Best is 1,2 with 35 other asteroids detected:

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
Best is 6,3 with 41 other asteroids detected:

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
Best is 11,13 with 210 other asteroids detected:

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

Find the best location for a new monitoring station. How many other asteroids can be detected from that location?
"""
  def read_asteroid_field(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index
    |> Enum.flat_map(fn {line, y} ->
      String.split(line, "", trim: true)
      |> Enum.with_index
      |> Enum.filter(fn
        {".", _} -> false
        {"#", _} -> true
      end)
      |> Enum.map(fn {_, x} -> {x, y} end)
    end)
  end

  def points_relative_to(points, {xo, yo}) do
    Enum.map(points, fn {x, y} ->
      {x - xo, y - yo}
    end)
  end

  def count_line_of_signt_from(station, asteroids) do
    lines = asteroids
    |> List.delete(station)
    |> points_relative_to(station)
    |> Enum.map(fn p -> line_from_origin(p) end)

    lines |> Enum.uniq |> Enum.count
  end

  def best_observation_point(asteroids) do
    asteroids
    |> Enum.map(fn asteroid ->
      {asteroid, count_line_of_signt_from(asteroid, asteroids)}
    end)
    |> Enum.max_by(fn {_, count} -> count end)
  end

  # Normalized line from line to origin, in reduced terms
  # The result {x, y} is actually the slope of the line m = (y / x)
  # Since its from the origin, the y-intercept is always 0
  # e.g
  # ({1, 1}) -> {1, 1}
  # ({2, 2}) -> {1, 1}
  def line_from_origin({0, y}), do: {sgn(y), 0}
  def line_from_origin({x, 0}), do: {0, sgn(x)}
  def line_from_origin({x, y}) when x < 0 or y < 0 do
    {pos_y, pos_x} = lowest_terms({abs(y), abs(x)})

    {sgn(y) * pos_y, sgn(x) * pos_x}
  end
  def line_from_origin({x, y}), do: lowest_terms({y, x})

  def sgn(x) when x < 0, do: -1
  def sgn(_), do: 1

  defp lowest_terms({x, 0}), do: {x, 0}
  defp lowest_terms({0, y}), do: {0, y}
  defp lowest_terms({x, y}) do
    gcd = greatest_common_divisor(x, y)

    {div(x, gcd), div(y, gcd)}
  end

  def greatest_common_divisor(a, a), do: a
  def greatest_common_divisor(a, b) when a > b, do: greatest_common_divisor(a - b, b)
  def greatest_common_divisor(a, b) when a < b, do: greatest_common_divisor(a, b - a)
end
