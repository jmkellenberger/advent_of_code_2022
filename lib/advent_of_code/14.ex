defmodule AdventOfCode.Day14 do
  @start {500, 0}

  def part1(input \\ "assets/14.txt") do
    map = parse(input)
    map = Map.put(map, :void, map.max_y)

    0
    |> Stream.iterate(&(&1 + 1))
    |> Enum.reduce_while(map, &drop_sand/2)
  end

  def part2(input \\ "assets/14.txt") do
    map = parse(input)
    map = Map.put(map, :floor, map.max_y + 2)

    0
    |> Stream.iterate(&(&1 + 1))
    |> Enum.reduce_while(map, &drop_sand/2)
  end

  def parse(input) do
    input
    |> File.read!()
    |> String.split("\n", trim: true)
    |> build_map(%{})
    |> put_bounds()
  end

  def build_map([], map), do: map

  def build_map([line | lines], map) do
    map =
      line
      |> parse_line()
      |> draw_lines(map)

    build_map(lines, map)
  end

  defp parse_line(line) do
    line
    |> String.split(~r/\D+/)
    |> Enum.map(&String.to_integer/1)
    |> Enum.chunk_every(2)
  end

  defp draw_lines([[xa, ya] | [[xb, yb] | _] = lines], map) do
    new_line =
      make_line(xa, ya, xb, yb)
      |> Enum.map(&{&1, "#"})
      |> Map.new()

    draw_lines(lines, Map.merge(map, new_line))
  end

  defp draw_lines(_, map), do: map

  defp make_line(x, ya, x, yb) do
    ya..yb
    |> Enum.map(&{x, &1})
  end

  defp make_line(xa, y, xb, y) do
    xa..xb
    |> Enum.map(&{&1, y})
  end

  def draw_line(y, range_x, map) do
    range_x
    |> Enum.map(fn x -> Map.get(map, {x, y}, ".") end)
    |> Enum.join()
  end

  defp put_bounds(map) do
    {min_x..max_x, min_y..max_y} = map |> Map.keys() |> bounds

    %{min_x: min_x, max_x: max_x, min_y: min_y, max_y: max_y}
    |> Map.merge(map)
  end

  defp bounds(coords) do
    {x, y} = Enum.unzip(coords)
    {Enum.min(x)..Enum.max(x), Enum.min(y)..Enum.max(y)}
  end

  defp drop_sand(sand, map) do
    case falling(@start, map) do
      :done -> {:halt, sand}
      new_map -> {:cont, new_map}
    end
  end

  defp falling({_, y} = pos, map) do
    if y < Map.get(map, :void) and is_nil(Map.get(map, @start)) do
      pos
      |> drop_directions()
      |> Enum.map(&{&1, get_block(map, &1)})
      |> case do
        [{new_pos, nil} | _] -> falling(new_pos, map)
        [_, {new_pos, nil}, _] -> falling(new_pos, map)
        [_, _, {new_pos, nil}] -> falling(new_pos, map)
        _ -> Map.put(map, pos, "o")
      end
    else
      :done
    end
  end

  defp drop_directions({x, y}) do
    [{x, y + 1}, {x - 1, y + 1}, {x + 1, y + 1}]
  end

  defp get_block(%{floor: floor}, {_, y}) when y >= floor do
    "#"
  end

  defp get_block(%{} = map, pos) do
    Map.get(map, pos)
  end
end
