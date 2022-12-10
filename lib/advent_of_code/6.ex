defmodule AdventOfCode.Day6 do
  @input File.read!("assets/6.txt")

  def part1(input \\ @input),
    do: find_marker_index(to_charlist(input), 4)

  def part2(input \\ @input),
    do: find_marker_index(to_charlist(input), 14)

  defp find_marker_index(input, size),
    do: eval_marker(input, size, 0, valid_marker?(input, size))

  defp eval_marker([], _, _, false), do: "No marker found"
  defp eval_marker(_input, size, index, true), do: size + index

  defp eval_marker([_first | tail], size, index, false),
    do: eval_marker(tail, size, index + 1, valid_marker?(tail, size))

  defp uniq(chunk), do: Enum.uniq(chunk) |> length
  defp valid_marker?(input, size) when length(input) < size, do: false
  defp valid_marker?(input, size), do: uniq(next_chunk(input, size)) == size
  defp next_chunk([head | tail], size), do: [head | Enum.take(tail, size - 1)]
end
