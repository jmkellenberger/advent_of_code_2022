defmodule AdventOfCode do
  alias AdventOfCode.{DayOne, DayTwo, DayThree, DayFour, DayFive}
  def day_one, do: format({DayOne.part_one(), DayOne.part_two()})
  def day_two, do: format({DayTwo.part_one(), DayTwo.part_two()})
  def day_three, do: format({DayThree.part_one(), DayThree.part_two()})
  def day_four, do: format({DayFour.part_one(), DayFour.part_two()})
  def day_five, do: format({DayFive.part_one(), DayFive.part_two()})

  defp format({one, two}), do: "Part One: #{one}, Part Two: #{two}"
end
