defmodule AdventOfCode.Day13 do
  def parse(input) do
    input
    |> File.read!()
    |> String.split("\n", trim: true)
  end

  def part1(input \\ "assets/13.txt") do
    input
    |> parse()
    |> Enum.map(&Code.string_to_quoted!(&1))
    |> Enum.chunk_every(2)
    |> Enum.map(fn [left, right] -> compare(left, right) end)
    |> Enum.with_index(1)
    |> Enum.filter(&(elem(&1, 0) == :correct))
    |> Enum.map(&elem(&1, 1))
    |> Enum.sum()
  end

  def part2(input \\ "assets/13.txt") do
    Enum.concat(["[[2]]", "[[6]]"], parse(input))
    |> Enum.map(fn line -> elem(Code.eval_string(line), 0) end)
    |> Enum.sort(fn a, b -> compare(a, b) != :wrong end)
    |> Enum.with_index(1)
    |> Enum.filter(fn
      {[[2]], _} -> true
      {[[6]], _} -> true
      {_, _} -> false
    end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.product()
  end

  defp compare(l, r) when is_integer(l) and is_integer(r) and l < r,
    do: :correct

  defp compare(l, r) when is_integer(l) and is_integer(r) and l > r, do: :wrong

  defp compare(l, r) when is_integer(l) and is_integer(r) and l == r,
    do: :continue

  defp compare(left, right) when is_integer(left), do: compare([left], right)
  defp compare(left, right) when is_integer(right), do: compare(left, [right])

  defp compare(left, right) when is_list(left) and is_list(right) do
    Enum.zip_reduce(
      Stream.concat(left, [:stop]),
      Stream.concat(right, [:stop]),
      :continue,
      fn
        _, _, :wrong -> :wrong
        _, _, :correct -> :correct
        :stop, :stop, _acc -> :continue
        :stop, _, _acc -> :correct
        _, :stop, _acc -> :wrong
        l, r, :continue -> compare(l, r)
      end
    )
  end
end
