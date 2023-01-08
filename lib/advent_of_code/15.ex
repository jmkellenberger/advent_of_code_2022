defmodule Day15 do
  @type coordinate :: {integer(), integer()}
  @type line :: {coordinate(), coordinate()}
  @type region :: %{origin: coordinate(), beacon: coordinate(), distance: integer()}
  @type input_pair :: %{sensor: coordinate(), beacon: coordinate()}
  @type input :: [input_pair]

  @example_input = """
  Sensor at x=2, y=18: closest beacon is at x=-2, y=15
  Sensor at x=9, y=16: closest beacon is at x=10, y=16
  Sensor at x=13, y=2: closest beacon is at x=15, y=3
  Sensor at x=12, y=14: closest beacon is at x=10, y=16
  Sensor at x=10, y=20: closest beacon is at x=10, y=16
  Sensor at x=14, y=17: closest beacon is at x=10, y=16
  Sensor at x=8, y=7: closest beacon is at x=2, y=10
  Sensor at x=2, y=0: closest beacon is at x=2, y=10
  Sensor at x=0, y=11: closest beacon is at x=2, y=10
  Sensor at x=20, y=14: closest beacon is at x=25, y=17
  Sensor at x=17, y=20: closest beacon is at x=21, y=22
  Sensor at x=16, y=7: closest beacon is at x=15, y=3
  Sensor at x=14, y=3: closest beacon is at x=15, y=3
  Sensor at x=20, y=1: closest beacon is at x=15, y=3
  """

  def solve_1(input, depth) do
   {points, beacons} = input
    |> String.split("\n", trim: true)
    |> Enum.flat_map(fn line ->
      String.split(line, ":", trim: true)
      |> Enum.map(&String.split(&1, "at ", trim: true))
      |> Enum.map(fn [_, coord] -> coord end)
      |> Enum.map(&String.split(&1, ", ", trim: true))
    end)
    |> Enum.map(fn ["x=" <> x, "y=" <> y] -> {String.to_integer(x), String.to_integer(y)} end)
    |> Enum.chunk_every(2)
    |> Enum.map(fn [sensor, beacon] -> %{sensor: sensor, beacon: beacon} end)
    |> Enum.map(&diamond/1)
    |> Enum.reduce({MapSet.new(), MapSet.new()}, fn diamond, {coords, beacons} ->
      case diamond_slice(diamond, depth) do
        nil ->
          {coords, MapSet.put(beacons, diamond[:beacon])}

        slice ->
          points =
            slice
            |> line_to_points()
            |> MapSet.new()

          {MapSet.union(points, coords), MapSet.put(beacons, diamond[:beacon])}
      end
    end)

    MapSet.difference(points, beacons)
    |> Enum.count()
  end

  defp line_to_points({{x1, y}, {x2, y}}) do
    Enum.map(x1..x2, &{&1, y})
  end

  defp manhattan_distance({x1, y1} = p1, {x2, y2} = p2) do
    corner_point = {x2, y1}

    (abs(distance(corner_point, p1)) + abs(distance(corner_point, p2)))
    |> trunc()
  end

  defp diamond(%{sensor: sensor, beacon: beacon}) do
    %{origin: sensor, distance: manhattan_distance(sensor, beacon), beacon: beacon}
  end

  defp distance({x1, y1} = p1, {x2, y2} = p2) do
    :math.sqrt(:math.pow(x2 - x1, 2) + :math.pow(y2 - y1, 2))
  end

  defp diamond_slice(%{distance: distance, origin: {_, y}}, depth)
       when depth not in (y - distance)..(y + distance),
       do: nil

  defp diamond_slice(%{distance: distance, origin: {x, y}} = diamond, depth) do
    modified_distance = distance - abs(depth - y)

    {{x - modified_distance, depth}, {x + modified_distance, depth}}
  end

  def overlaps?(min1..max1, min2..max2) do
    max(min1,max1) <= min(min2,max2)
    # min2 <= max1 && min2 >= min1 || max2 >= min1 && max2 <= max1
  end
end
