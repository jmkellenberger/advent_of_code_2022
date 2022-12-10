defmodule AdventOfCode do
  alias AdventOfCode.{
    Day1,
    Day2,
    Day3,
    Day4,
    Day5,
    Day6,
    Day7,
    Day8,
    Day9
  }

  def day1, do: format({Day1.part1(), Day1.part2()})
  def day2, do: format({Day2.part1(), Day2.part2()})
  def day3, do: format({Day3.part1(), Day3.part2()})
  def day4, do: format({Day4.part1(), Day4.part2()})
  def day5, do: format({Day5.part1(), Day5.part2()})
  def day6, do: format({Day6.part1(), Day6.part2()})
  def day7, do: format({Day7.part1(), Day7.part2()})
  def day8, do: format({Day8.part1(), Day8.part2()})
  def day9, do: format({Day9.part1(), Day9.part2()})
  defp format({one, two}), do: "Part One: #{one}, Part Two: #{two}"
end
