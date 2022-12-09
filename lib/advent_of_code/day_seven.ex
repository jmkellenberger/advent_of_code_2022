defmodule AdventOfCode.DaySeven do
  @input File.read!("assets/day_seven.txt")
         |> String.split("\n", trim: true)

  def part_one do
    get_dirs()
    |> Enum.filter(&(&1 <= 100_000))
    |> Enum.sum()
  end

  @total_space 70_000_000
  @needed_space 30_000_000

  def part_two do
    dirs = get_dirs()
    unused = @total_space - (dirs |> hd())

    Enum.filter(dirs, &(unused + &1 >= @needed_space))
    |> Enum.sort(:asc)
    |> hd()
  end

  defp get_dirs(input \\ @input),
    do: parse_dirs(input, [], %{}) |> Map.values() |> Enum.sort(:desc)

  defp parse_dirs([], _path, sizes), do: sizes

  defp parse_dirs(["$ cd /" | lines], _path, sizes),
    do: parse_dirs(lines, ["/"], sizes)

  defp parse_dirs([line | lines], [_current | dirs] = path, sizes) do
    {command, arg} = parse_command(line)

    case {command, arg} do
      {:cd, ".."} ->
        parse_dirs(lines, dirs, sizes)

      {:cd, dir} ->
        parse_dirs(lines, [dir | path], sizes)

      {:file, size} ->
        sizes = add_file(size, path, sizes)
        parse_dirs(lines, path, sizes)

      _ ->
        parse_dirs(lines, path, sizes)
    end
  end

  defp parse_command("$ ls"), do: {:ls, ""}
  defp parse_command("$ cd " <> arg), do: {:cd, arg}
  defp parse_command("dir " <> dir_name), do: {:dir, dir_name}

  defp parse_command(line) do
    [size, _name] = String.split(line, " ", trim: true)
    {:file, String.to_integer(size)}
  end

  defp add_file(_size, [], sizes), do: sizes

  defp add_file(size, [_dir | rest] = path, sizes) do
    path = format_path(path)
    val = Map.get(sizes, path, 0) + size
    sizes = Map.put(sizes, path, val)
    add_file(size, rest, sizes)
  end

  defp format_path(["/"]), do: "/"

  defp format_path(path) do
    [root | rest] = Enum.reverse(path)
    "#{root}#{Enum.join(rest, "/")}"
  end
end
