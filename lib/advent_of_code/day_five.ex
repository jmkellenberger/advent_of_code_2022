defmodule AdventOfCode.DayFive do
  @input File.read!("assets/day_five.txt")
         |> String.split(~r/\n/)
         |> Enum.chunk_by(&(&1 == ""))
  def process_input do
    [crates, _, commands, _] = @input
    crates = parse_crate_positions(Enum.reverse(crates))
    commands = Enum.map(commands, &String.split(&1, " ", trim: true))
    {crates, commands}
  end

  def part_one do
    {crates, commands} = process_input()
    crates = run_commands(crates, :one, commands)

    for n <- 1..9 do
      Map.get(crates, n) |> hd() |> String.replace(["[", "]"], "")
    end
    |> Enum.join()
  end

  def part_two do
    {crates, commands} = process_input()
    crates = run_commands(crates, :two, commands)

    for n <- 1..9 do
      Map.get(crates, n) |> hd() |> String.replace(["[", "]"], "")
    end
    |> Enum.join()
  end

  defp parse_crate_positions([stacks | crates]) do
    map = build_crate_map(stacks)

    Enum.map(crates, fn layer ->
      [0..2, 4..6, 8..10, 12..14, 16..18, 20..22, 24..26, 28..30, 32..34]
      |> Enum.map(&String.slice(layer, &1))
      |> Enum.with_index()
    end)
    |> List.flatten()
    |> stack_crates(map)
  end

  defp stack_crates(crates, map) do
    Enum.reduce(crates, map, fn {x, i}, acc ->
      if(x != "   ") do
        Map.update!(acc, i + 1, &[x | &1])
      else
        acc
      end
    end)
  end

  defp build_crate_map(stacks) do
    stacks
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Map.from_keys([])
  end

  def run_commands(crates, _part, []), do: crates

  def run_commands(crates, part, [command | rest]) do
    crates = do_command(crates, part, command)
    run_commands(crates, part, rest)
  end

  defp read_command(["move", qty, "from", origin, "to", destination]) do
    [qty, origin, destination] |> Enum.map(&String.to_integer/1)
  end

  defp do_command(crates, part, command) do
    [qty, origin, destination | _] = read_command(command)

    move(crates, qty, origin, destination, part)
  end

  defp move(crates, 0, _origin, _destination, _part), do: crates

  defp move(crates, qty, origin, destination, :one) do
    {crate, crates} = pop(crates, origin)
    crates = push(crates, crate, destination)
    move(crates, qty - 1, origin, destination, :one)
  end

  defp move(crates, qty, origin, destination, :two) do
    stack = Map.get(crates, origin)
    IO.inspect(stack)
    {to_shift, rest} = Enum.split(stack, qty)
    crates = Map.put(crates, origin, rest)

    Map.update!(crates, destination, &(to_shift ++ &1))
  end

  defp pop(crates, stack) do
    [crate | rest] = Map.get(crates, stack)
    crates = Map.put(crates, stack, rest)
    {crate, crates}
  end

  defp push(crates, crate, destination) do
    Map.update!(crates, destination, &[crate | &1])
  end
end
