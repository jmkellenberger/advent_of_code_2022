defmodule AdventOfCode.DayOne do
  @input File.read!("assets/day_one.txt")
         |> String.split(~r/\n/)
         |> Enum.chunk_by(&(&1 == ""))
         |> Enum.reject(&(&1 == [""]))
         |> Enum.map(
           &Enum.reduce(&1, 0, fn n, acc -> String.to_integer(n) + acc end)
         )
         |> Enum.sort(:desc)

  def part_one do
    hd(@input)
  end

  def part_two do
    [first, second, third | _] = @input
    first + second + third
  end
end
