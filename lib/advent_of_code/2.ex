defmodule AdventOfCode.Day2 do
  @input File.read!("assets/2.txt")
         |> String.split(~r/\n/, trim: true)

  def part1,
    do: Enum.reduce(@input, 0, fn match, acc -> score_match(match) + acc end)

  def score_match("A X"), do: 4
  def score_match("A Y"), do: 8
  def score_match("A Z"), do: 3
  def score_match("B X"), do: 1
  def score_match("B Y"), do: 5
  def score_match("B Z"), do: 9
  def score_match("C X"), do: 7
  def score_match("C Y"), do: 2
  def score_match("C Z"), do: 6

  def part2,
    do: Enum.reduce(@input, 0, fn match, acc -> fix_match(match) + acc end)

  # X means you need to lose,
  # Y means you need to end the round in a draw, and
  # Z means you need to win. Good luck!"
  def fix_match("A X"), do: 3
  def fix_match("A Y"), do: 4
  def fix_match("A Z"), do: 8
  def fix_match("B X"), do: 1
  def fix_match("B Y"), do: 5
  def fix_match("B Z"), do: 9
  def fix_match("C X"), do: 2
  def fix_match("C Y"), do: 6
  def fix_match("C Z"), do: 7
end
