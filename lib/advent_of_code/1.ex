defmodule AdventOfCode.Day1 do
  @input File.read!("assets/1.txt")
         |> String.split(~r/\n/)
         |> Enum.chunk_by(&(&1 == ""))
         |> Enum.reject(&(&1 == [""]))
         |> Enum.map(
           &Enum.reduce(&1, 0, fn n, acc -> String.to_integer(n) + acc end)
         )
         |> Enum.sort(:desc)

  def part1 do
    hd(@input)
  end

  def part2 do
    [first, second, third | _] = @input
    first + second + third
  end
end
