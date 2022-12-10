defmodule AdventOfCode.Day9 do
  alias AdventOfCode.Day9.{Input, Point, Rope, Simulation}

  @type simulation :: Simulation.t()
  @type rope :: Rope.t()
  @type point :: Point.t()
  @type cmd ::
          :up
          | :right
          | :down
          | :left
          | :up_right
          | :up_left
          | :down_right
          | :down_left

  @spec part1 :: non_neg_integer
  def part1 do
    Input.load()
    |> Simulation.new(2)
    |> Simulation.run()
  end

  @spec part2 :: non_neg_integer
  def part2 do
    Input.load()
    |> Simulation.new(10)
    |> Simulation.run()
  end
end
