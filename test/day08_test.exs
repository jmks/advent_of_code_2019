defmodule Day08Test do
  use ExUnit.Case, async: true

  import Day08

  test "splitting into layers" do
    assert split_layers(3, 2, "123456789012") == [
      [
        [1,2,3],
        [4,5,6]
      ],
      [
        [7, 8, 9],
        [0, 1, 2]
      ]
    ]
  end

  test "check" do
    layers = split_layers(3, 2, "123456789012")

    assert check(layers) == 1
  end
end
