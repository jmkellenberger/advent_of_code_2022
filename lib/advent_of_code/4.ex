defmodule AdventOfCode.Day4 do
  @input File.read!("assets/4.txt")
         |> String.split(~r/\n/, trim: true)
         |> Enum.map(fn line ->
           [_, a, b, c, d] = Regex.run(~r/(\d+)-(\d+),(\d+)-(\d+)/, line)
           [a, b, c, d] |> Enum.map(&String.to_integer/1)
         end)

  def part1 do
    @input
    |> Enum.reduce(0, fn [a, b, c, d], acc ->
      set1 = MapSet.new(a..b)
      set2 = MapSet.new(c..d)

      if MapSet.subset?(set1, set2) or MapSet.subset?(set2, set1) do
        1 + acc
      else
        acc
      end
    end)
  end

  def part2 do
    @input
    |> Enum.reduce(0, fn [a, b, c, d], acc ->
      case Range.disjoint?(a..b, c..d) do
        true -> acc
        false -> acc + 1
      end
    end)
  end
end
