defmodule AdventOfCode.Day3 do
  @input File.read!("assets/3.txt")
         |> String.split(~r/\n/, trim: true)

  @item_priority (Enum.map(?a..?z, fn x -> <<x::utf8>> end) ++
                    Enum.map(?A..?Z, fn x -> <<x::utf8>> end))
                 |> Enum.zip(1..52)
                 |> Enum.into(%{})

  def part1,
    do:
      Enum.reduce(@input, 0, fn rucksack, acc ->
        find_item_common_to_both_compartments(rucksack) + acc
      end)

  def part2 do
    @input
    |> Enum.chunk_every(3)
    |> Enum.reduce(0, fn group, acc -> find_badge_value(group) + acc end)
  end

  defp find_item_common_to_both_compartments(rucksack) do
    rucksack
    |> split_rucksack()
    |> get_common_items()
    |> get_item_priority()
  end

  defp find_badge_value(group) do
    group
    |> get_common_items()
    |> get_item_priority()
  end

  defp split_rucksack(rucksack) do
    midpoint = (String.length(rucksack) / 2) |> trunc()
    String.split_at(rucksack, midpoint) |> Tuple.to_list()
  end

  defp get_common_items(group) do
    group
    |> Enum.map(
      &(String.split(&1, "", trim: true)
        |> MapSet.new())
    )
    |> Enum.reduce(&MapSet.intersection/2)
    |> MapSet.to_list()
    |> Enum.join()
  end

  defp get_item_priority(item), do: @item_priority[item]
end
