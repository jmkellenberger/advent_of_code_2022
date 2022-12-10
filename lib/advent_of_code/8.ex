defmodule AdventOfCode.Day8 do
  @input File.read!("assets/8.txt")
         |> String.split("\n", trim: true)
         |> Enum.map(&String.graphemes(&1))
         |> Enum.map(fn line -> Enum.map(line, &String.to_integer(&1)) end)
         |> Enum.map(fn line ->
           Enum.with_index(line) |> Map.new(fn {v, k} -> {k, v} end)
         end)
         |> Enum.with_index()
         |> Map.new(fn {v, k} -> {k, v} end)

  def part1(trees \\ @input) do
    {ht, wd} = grid_sizes(trees)
    perimeter = (wd + ht) * 2

    for x <- 1..(ht - 2),
        y <- 1..(wd - 2),
        visible?(x, y, trees),
        reduce: perimeter do
      acc ->
        acc + 1
    end
  end

  def part2(trees \\ @input) do
    {ht, wd} = grid_sizes(trees)

    for x <- 1..(ht - 2),
        y <- 1..(wd - 2),
        reduce: -1 do
      acc ->
        max(acc, scenic_score(x, y, trees[y][x], trees))
    end
  end

  defp grid_sizes(trees), do: {map_size(trees), map_size(trees[0])}

  @dirs [:left, :right, :top, :bottom]

  defp visible?(x, y, trees) do
    Enum.any?(@dirs, fn dir ->
      visible_from?(dir, x, y, trees[y][x], trees)
    end)
  end

  defp visible_from?(dir, x, y, tree, trees) do
    neighbors(dir, x, y, trees)
    |> Enum.all?(&taller?(dir, &1, x, y, tree, trees))
  end

  defp neighbors(:left, x, _, _), do: 0..(x - 1)
  defp neighbors(:right, x, _, trees), do: (x + 1)..(map_size(trees[x]) - 1)
  defp neighbors(:top, _, y, _), do: 0..(y - 1)
  defp neighbors(:bottom, _, y, trees), do: (y + 1)..(map_size(trees) - 1)

  defp scenic_score(x, y, tree, trees) do
    Enum.reduce(@dirs, 1, fn dir, acc ->
      acc *
        (neighbors_max(dir, x, y, trees)
         |> max_visibility(dir, x, y, tree, trees))
    end)
  end

  defp max_visibility(neighbors, dir, x, y, tree, trees),
    do:
      Enum.reduce_while(
        neighbors,
        0,
        &check_neighbors(dir, &1, x, y, tree, trees, &2)
      )

  defp neighbors_max(:left, x, _, _), do: (x - 1)..0
  defp neighbors_max(:top, _, y, _), do: (y - 1)..0

  defp neighbors_max(:right, x, _, trees),
    do: (x + 1)..(map_size(trees[0]) - 1)

  defp neighbors_max(:bottom, x, y, trees), do: neighbors(:bottom, x, y, trees)

  defp taller?(dir, current, x, _y, height, heights)
       when dir in [:top, :bottom],
       do: heights[current][x] < height

  defp taller?(dir, current, _x, y, height, heights)
       when dir in [:left, :right],
       do: heights[y][current] < height

  defp check_neighbors(dir, current, x, y, height, heights, acc) do
    taller?(dir, current, x, y, height, heights) |> check_neighbor(acc)
  end

  defp check_neighbor(true, acc), do: {:cont, acc + 1}
  defp check_neighbor(false, acc), do: {:halt, acc + 1}
end
