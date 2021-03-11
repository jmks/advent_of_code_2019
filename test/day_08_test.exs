defmodule Day08Test do
  use ExUnit.Case, async: true

  import Day08

  test "splitting into layers" do
    assert split_layers(3, 2, "123456789012") == [
             [
               [1, 2, 3],
               [4, 5, 6]
             ],
             [
               [7, 8, 9],
               [0, 1, 2]
             ]
           ]

    [
      [[1, 7], [2, 8], [3, 9]],
      [[4, 0], [5, 1], [6, 2]]
    ]
  end

  test "check" do
    layers = split_layers(3, 2, "123456789012")

    assert check(layers) == 1
  end

  test "colour" do
    assert colour([0, 1, 2, 0]) == 0
    assert colour([2, 1, 2, 0]) == 1
    assert colour([2, 2, 1, 0]) == 1
    assert colour([2, 2, 2, 0]) == 0
  end

  test "decode image" do
    layers = split_layers(2, 2, "0222112222120000")

    assert decode(2, 2, layers) == [
             [0, 1],
             [1, 0]
           ]
  end
end
