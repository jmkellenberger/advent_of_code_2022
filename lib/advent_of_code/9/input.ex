defmodule AdventOfCode.Day9.Input do
  @input File.read!("assets/9.txt")
         |> String.split("\n", trim: true)

  @spec load([String.t()]) :: [Day9.cmd()]
  def load(input \\ @input), do: parse_commands(input)

  @spec parse_commands([String.t()]) :: [Day9.cmd()]
  defp parse_commands(data),
    do: Enum.map(data, &read_line/1) |> List.flatten()

  @spec read_line(String.t()) :: Day9.cmd()
  defp read_line("U " <> n), do: add_commands(:up, String.to_integer(n))
  defp read_line("D " <> n), do: add_commands(:down, String.to_integer(n))
  defp read_line("R " <> n), do: add_commands(:right, String.to_integer(n))
  defp read_line("L " <> n), do: add_commands(:left, String.to_integer(n))

  defp add_commands(command, amount),
    do: Enum.map(1..amount, fn _ -> command end)
end
