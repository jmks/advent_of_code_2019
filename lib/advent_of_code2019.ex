defmodule AdventOfCode2019 do
  def read_input(day) when is_binary(day) do
    read_raw(day)
    |> String.split("\n", trim: true)
  end

  def read_raw(day) when is_binary(day) do
    File.read!("data/#{day}")
  end

  def read_line_of_cs_ints(day) do
    read_input(day) |> hd |> String.split(",") |> Enum.map(fn x ->
      {int, ""} = Integer.parse(x)
      int
    end)
  end
end
