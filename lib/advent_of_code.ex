defmodule AdventOfCode do
  @doc """
  Read in a list of calories carried by elves, seperated by blank lines.
  Find number of calories carried by the elf with the most snacks.
  """
  def day_one do
    File.read!("assets/day_one.txt")
    |> String.split(~r/\n/)
    |> Enum.chunk_by(&(&1 == ""))
    |> Enum.reject(&(&1 == [""]))
    |> Enum.map(
      &Enum.reduce(&1, 0, fn n, acc -> String.to_integer(n) + acc end)
    )
    |> Enum.sort(:desc)
  end

  def day_one_part_one do
    hd(day_one())
  end

  def day_one_part_two do
    [first, second, third | _] = day_one()
    first + second + third
  end
end
