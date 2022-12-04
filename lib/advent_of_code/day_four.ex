defmodule AdventOfCode.DayFour do
  @input File.read!("assets/day_four.txt")
         |> String.split(~r/\n/, trim: true)

  def part_one do
    @input
    |> Enum.reduce(0, &(check_subset(&1) + &2))
  end

  def part_two do
  end

  defp check_subset(line) do
    line
    |> String.split(",", trim: true)
    |> to_ranges
    |> to_sets
    |> subsets?
  end

  defp to_ranges([first, second | _]) do
    [min1, max1] =
      String.split(first, "-", trim: true) |> Enum.map(&String.to_integer/1)

    [min2, max2] =
      String.split(second, "-", trim: true) |> Enum.map(&String.to_integer/1)

    {min1..max1, min2..max2}
  end

  @spec to_sets({any, any}) :: {MapSet.t(), MapSet.t()}
  defp to_sets({range1, range2}), do: {MapSet.new(range1), MapSet.new(range2)}

  defp subsets?({set1, set2}) do
    if MapSet.subset?(set1, set2) or MapSet.subset?(set2, set1) do
      1
    else
      0
    end
  end
end
