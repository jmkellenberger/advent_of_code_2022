defmodule AdventOfCode.Day12 do
  @type point :: {non_neg_integer(), non_neg_integer()}
  @type height_map :: %{point => non_neg_integer()}

  @spec part1(String.t()) :: pos_integer
  def part1(input \\ "assets/12.txt") do
    shortest_path(input, fn dists, _, start -> Map.put(dists, start, 0) end)
  end

  @spec part2(String.t()) :: pos_integer
  def part2(input \\ "assets/12.txt") do
    shortest_path(input, fn distances, heights, _ ->
      heights
      |> Enum.filter(fn {_, h} -> h == 0 end)
      |> Enum.map(&elem(&1, 0))
      |> Enum.reduce(distances, &Map.put(&2, &1, 0))
    end)
  end

  defp setup(input) do
    map =
      input
      |> File.read!()
      |> String.split("\n", trim: true)
      |> Enum.map(&String.codepoints/1)
      |> Enum.with_index()
      |> Enum.flat_map(fn {row, y} ->
        row
        |> Enum.with_index()
        |> Enum.map(fn {height, x} -> {{x, y}, height} end)
      end)

    start = map |> Enum.find(fn {_, v} -> v == "S" end) |> elem(0)
    goal = map |> Enum.find(fn {_, v} -> v == "E" end) |> elem(0)

    heights =
      map
      |> Enum.map(fn
        {k, "S"} -> {k, 0}
        {k, "E"} -> {k, 25}
        {k, <<v>>} -> {k, v - ?a}
      end)
      |> Map.new()

    {start, goal, heights}
  end

  defp shortest_path(input, transform) do
    {start, goal, heights} = setup(input)

    heights
    |> Map.keys()
    |> Map.new(&{&1, :infinity})
    |> transform.(heights, start)
    |> dijkstra(heights, goal)
  end

  defp dijkstra(distances, heights, goal) do
    case Enum.min_by(distances, &elem(&1, 1)) do
      {^goal, dist} ->
        dist

      {current, dist} ->
        current
        |> neighbors(heights)
        |> Enum.reduce(distances, fn n, distances ->
          Map.replace_lazy(distances, n, &min(&1, dist + 1))
        end)
        |> Map.delete(current)
        |> dijkstra(heights, goal)
    end
  end

  defp neighbors({x, y} = point, heights) do
    [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]
    |> Enum.filter(&(heights[&1] <= heights[point] + 1))
  end
end
