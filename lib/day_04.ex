defmodule Day04 do
  @moduledoc """
  --- Day 4: Secure Container ---

  You arrive at the Venus fuel depot only to discover it's protected by a password. The Elves had written the password on a sticky note, but someone threw it out.

  However, they do remember a few key facts about the password:

  It is a six-digit number.
  The value is within the range given in your puzzle input.
  Two adjacent digits are the same (like 22 in 122345).
  Going from left to right, the digits never decrease; they only ever increase or stay the same (like 111123 or 135679).
  Other than the range rule, the following are true:

  111111 meets these criteria (double 11, never decreases).
  223450 does not meet these criteria (decreasing pair of digits 50).
  123789 does not meet these criteria (no double).

  How many different passwords within the range given in your puzzle input meet these criteria?

  --- Part Two ---

  An Elf just remembered one more important detail: the two adjacent matching digits are not part of a larger group of matching digits.

  Given this additional criterion, but still ignoring the range rule, the following are now true:

  112233 meets these criteria because the digits never decrease and all repeated digits are exactly two digits long.
  123444 no longer meets the criteria (the repeated 44 is part of a larger group of 444).
  111122 meets the criteria (even though 1 is repeated more than twice, it still contains a double 22).
  How many different passwords within the range given in your puzzle input meet all of the criteria?

"""
  def valid?(password) when is_integer(password) do
    digits = Integer.digits(password)

    length(digits) == 6 && repeated_digit?(digits) && monotonically_increasing_digits?(digits)
  end

  def stricter_valid?(password) when is_integer(password) do
    digits = Integer.digits(password)

    length(digits) == 6 && at_least_one_duplicate_digit?(digits) && monotonically_increasing_digits?(digits)
  end

  defp repeated_digit?([]), do: false
  defp repeated_digit?([_]), do: false
  defp repeated_digit?([a, a | _]), do: true
  defp repeated_digit?([_, b | rest]), do: repeated_digit?([b | rest])

  defp monotonically_increasing_digits?([]), do: true
  defp monotonically_increasing_digits?([_]), do: true
  defp monotonically_increasing_digits?([a, b | rest]) when a <= b, do: monotonically_increasing_digits?([b | rest])
  defp monotonically_increasing_digits?(_), do: false

  defp at_least_one_duplicate_digit?(digits) do
    digit_counts = Enum.reduce(digits, Map.new, fn d, acc ->
      Map.update(acc, d, 1, fn x -> x + 1 end)
    end)
    duplicated_exactly_twice =
      digit_counts
    |> Enum.filter(fn {_, c} -> c == 2 end)
    |> Enum.map(fn {k, _} -> k end)

    length(duplicated_exactly_twice) >= 1
  end

  def valid_within(first, last) do
    Enum.count(Range.new(first, last), &valid?/1)
  end

  def stricter_valid_within(first, last) do
    Enum.count(Range.new(first, last), &stricter_valid?/1)
  end
end
