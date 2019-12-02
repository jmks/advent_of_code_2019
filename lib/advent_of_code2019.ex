defmodule AdventOfCode2019 do
  def read_input(day) when is_binary(day) do
    File.read!("data/#{day}")
    |> String.split("\n")
  end
end
