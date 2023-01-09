defmodule Day15 do
  @type coordinate :: {integer(), integer()}
  @type line :: {coordinate(), coordinate()}
  @type region :: %{
          origin: coordinate(),
          beacon: coordinate(),
          distance: integer()
        }
  @type input_pair :: %{sensor: coordinate(), beacon: coordinate()}
  @type input :: [input_pair]

  @example """
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
    {points, beacons} =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&get_input_pair/1)
      |> Enum.map(&diamond/1)
      |> Enum.reduce({MapSet.new(), MapSet.new()}, fn diamond,
                                                      {coords, beacons} ->
        case diamond_slice(diamond, depth) do
          nil ->
            {coords, MapSet.put(beacons, diamond[:beacon])}

          slice ->
            points =
              slice
              |> line_to_points()
              |> MapSet.new()

            {MapSet.union(points, coords),
             MapSet.put(beacons, diamond[:beacon])}
        end
      end)

    MapSet.difference(points, beacons)
    |> Enum.count()
  end

  defp get_input_pair(line) do
    [_ | coords] =
      Regex.run(
        ~r/x=(?<x1>-?\d+), y=(?<y1>-?\d+).*x=(?<x2>-?\d+), y=(?<y2>-?\d+)/,
        line
      )

    [sensor_x, sensor_y, beacon_x, beacon_y] =
      Enum.map(coords, &String.to_integer/1)

    %{sensor: {sensor_x, sensor_y}, beacon: {beacon_x, beacon_y}}
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
    %{
      origin: sensor,
      distance: manhattan_distance(sensor, beacon),
      beacon: beacon
    }
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

  def overlaps?(range1, range2) do
    Range.disjoint?(range1, range2)
  end
end
