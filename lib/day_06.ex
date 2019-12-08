defmodule Day06 do
  @moduledoc """
--- Day 6: Universal Orbit Map ---

You've landed at the Universal Orbit Map facility on Mercury. Because navigation in space often involves transferring between orbits, the orbit maps here are useful for finding efficient routes between, for example, you and Santa. You download a map of the local orbits (your puzzle input).

Except for the universal Center of Mass (COM), every object in space is in orbit around exactly one other object. An orbit looks roughly like this:

                  \
                   \
                    |
                    |
AAA--> o            o <--BBB
                    |
                    |
                   /
                  /
In this diagram, the object BBB is in orbit around AAA. The path that BBB takes around AAA (drawn with lines) is only partly shown. In the map data, this orbital relationship is written AAA)BBB, which means "BBB is in orbit around AAA".

Before you use your map data to plot a course, you need to make sure it wasn't corrupted during the download. To verify maps, the Universal Orbit Map facility uses orbit count checksums - the total number of direct orbits (like the one shown above) and indirect orbits.

Whenever A orbits B and B orbits C, then A indirectly orbits C. This chain can be any number of objects long: if A orbits B, B orbits C, and C orbits D, then A indirectly orbits D.

For example, suppose you have the following map:

COM)B
B)C
C)D
D)E
E)F
B)G
G)H
D)I
E)J
J)K
K)L

Visually, the above map of orbits looks like this:

        G - H       J - K - L
       /           /
COM - B - C - D - E - F
               \
                I
In this visual representation, when two objects are connected by a line, the one on the right directly orbits the one on the left.

Here, we can count the total number of orbits as follows:

D directly orbits C and indirectly orbits B and COM, a total of 3 orbits.
L directly orbits K and indirectly orbits J, E, D, C, B, and COM, a total of 7 orbits.
COM orbits nothing.
The total number of direct and indirect orbits in this example is 42.

What is the total number of direct and indirect orbits in your map data?

Now, you just need to figure out how many orbital transfers you (YOU) need to take to get to Santa (SAN).

You start at the object YOU are orbiting; your destination is the object SAN is orbiting. An orbital transfer lets you move from any object to an object orbiting or orbited by that object.

For example, suppose you have the following map:

COM)B
B)C
C)D
D)E
E)F
B)G
G)H
D)I
E)J
J)K
K)L
K)YOU
I)SAN
Visually, the above map of orbits looks like this:

                          YOU
                         /
        G - H       J - K - L
       /           /
COM - B - C - D - E - F
               \
                I - SAN
In this example, YOU are in orbit around K, and SAN is in orbit around I. To move from K to I, a minimum of 4 orbital transfers are required:

K to J
J to E
E to D
D to I
Afterward, the map of orbits looks like this:

        G - H       J - K - L
       /           /
COM - B - C - D - E - F
               \
                I - SAN
                 \
                  YOU

What is the minimum number of orbital transfers required to move from the object YOU are orbiting to the object SAN is orbiting? (Between the objects they are orbiting - not between YOU and SAN.)

"""

  import AdventOfCode2019

  def parse_orbit(orbit) do
    [source, orbiter] = String.split(orbit, ")")

    {source, orbiter}
  end

  def distance_to_com(source, map), do: do_distance_to_com(source, map, 0)

  defp do_distance_to_com("COM", _, d), do: d
  defp do_distance_to_com(prev, map, d) do
    next = Map.get(map, prev)

    do_distance_to_com(next, map, d + 1)
  end

  def count_orbits(raw_orbits) do
    orbits = Enum.map(raw_orbits, &parse_orbit/1)

    orbits_map = Enum.into(orbits, %{}, fn {x, y} -> {y, x} end)

    orbits
    |> Enum.map(fn {_, x} -> distance_to_com(x, orbits_map) end)
    |> Enum.sum
  end

  def solve_one do
    read_input("06") |> count_orbits
  end

  def orbital_transfers(raw_orbits, target_orbiting_with) do
    orbits = Enum.map(raw_orbits, &parse_orbit/1)
    orbits_map = Enum.into(orbits, %{}, fn {x, y} -> {y, x} end)

    orbited_by_map = Enum.reduce(orbits_map, %{}, fn {o, com}, map ->
      Map.update(map, com, [o], fn orbited_by ->
        orbited_by ++ [o]
      end)
    end)

    source = orbits_map["YOU"]
    target = orbits_map[target_orbiting_with]
    path = dfs(target, orbits_map, orbited_by_map, [{source, [source]}])

    length(path) - 1
  end

  defp dfs(target, orbits_map, orbited_by_map, queue)

  defp dfs(_target, _orbits_map, _orbited_by_map, []), do: :no_path_found

  defp dfs(target, _orbits_map, _orbited_by_map, [{target, visited} | _queue]), do: Enum.reverse(visited)

  defp dfs(target, orbits_map, orbited_by_map, [{current, visited} | queue]) do
    potential_orbits = Map.get(orbited_by_map, current, []) ++ [orbits_map[current]]
    next_orbits = MapSet.difference(MapSet.new(potential_orbits), MapSet.new(visited)) |> MapSet.to_list

    if Enum.any?(next_orbits) do
      new_queue_entries = Enum.map(next_orbits, fn o -> {o, [o | visited]} end)

      dfs(target, orbits_map, orbited_by_map, queue ++ new_queue_entries)
    else
      dfs(target, orbits_map, orbited_by_map, queue)
    end
  end

  def solve_two do
    read_input("06") |> orbital_transfers("SAN")
  end
end
