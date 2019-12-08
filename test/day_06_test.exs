defmodule Day06Test do
  use ExUnit.Case, async: true

  import Day06

  @orbits [
    "COM)B",
    "B)C",
    "C)D",
    "D)E",
    "E)F",
    "B)G",
    "G)H",
    "D)I",
    "E)J",
    "J)K",
    "K)L"
  ]

  test "parse orbit" do
    assert parse_orbit("COM)B") == {"COM", "B"}
    assert parse_orbit("B)C") == {"B", "C"}
  end

  test "distance to COM" do
    orbits = @orbits |> Enum.map(&parse_orbit/1) |> Enum.into(%{}, fn {x, y} -> {y, x} end)

    assert distance_to_com("COM", orbits) == 0
    assert distance_to_com("B", orbits) == 1
    assert distance_to_com("G", orbits) == 2
    assert distance_to_com("H", orbits) == 3
    assert distance_to_com("L", orbits) == 7
  end

  test "count orbits" do
    assert count_orbits(@orbits) == 42
  end

  test "orbital transfers" do
    orbits = @orbits ++ ["K)YOU", "I)SAN"]

    assert orbital_transfers(orbits, "SAN") == 4
  end
end
