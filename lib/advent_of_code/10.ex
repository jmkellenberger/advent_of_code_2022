defmodule AdventOfCode.Day10 do
  defmodule Input do
    @spec parse(0 | 1 | 2) :: [Day10.cmd()]
    def parse(data) do
      case(data) do
        0 -> "assets/10.txt"
        1 -> "assets/10test1.txt"
        2 -> "assets/10test2.txt"
      end
      |> File.read!()
      |> String.split("\n", trim: true)
      |> Enum.map(&read_line/1)
    end

    @spec read_line(String.t()) :: Day10.cmd()
    defp read_line("noop"), do: :noop
    defp read_line("addx " <> n), do: {:addx, String.to_integer(n)}
  end

  defmodule Simulation do
    defstruct [:cycle, :registry, :history]

    @opaque t :: %__MODULE__{
              cycle: pos_integer(),
              registry: integer(),
              history: history
            }
    @type history :: %{pos_integer => integer()}
    @spec new() :: t
    def new(),
      do: %__MODULE__{cycle: 1, registry: 1, history: %{1 => 1}}

    @spec run(t, [Day9.cmd()]) :: t
    def run(sim, []), do: sim

    def run(sim, [:noop | rest]),
      do:
        sim
        |> tick
        |> run(rest)

    def run(sim, [{:addx, x} | rest]),
      do:
        sim
        |> tick
        |> add_x(x)
        |> tick
        |> run(rest)

    @spec tick(t) :: t
    defp tick(%{cycle: cycle} = sim),
      do:
        sim
        |> Map.put(:cycle, cycle + 1)
        |> update_history

    @spec update_history(t) :: t
    defp update_history(
           %__MODULE__{cycle: cycle, history: history, registry: reg} = sim
         ),
         do: %{sim | history: Map.put(history, cycle, reg)}

    @spec add_x(t, integer()) :: t
    defp add_x(%{registry: reg} = sim, x),
      do: Map.put(sim, :registry, reg + x)

    @spec slice_history(t, Range.t()) :: [integer()]
    def slice_history(%{history: history}, range),
      do: Enum.map(range, &history[&1])

    @spec render(t) :: [String.t()]
    def render(sim), do: Enum.map(1..6, &draw_row(sim, &1))

    @spec draw_row(t, integer) :: String.t()
    defp draw_row(sim, row) do
      sim
      |> slice_history((1 + 40 * (row - 1))..(40 * row))
      |> Enum.with_index()
      |> Enum.map(fn {x, pix} ->
        case pix in (x - 1)..(x + 1) do
          true -> "#"
          false -> " "
        end
      end)
      |> Enum.join("")
    end
  end

  @type simulation :: Simulation.t()
  @type cmd :: :noop | {:addx, integer()}

  @spec part1 :: integer()
  def part1 do
    setup()
    |> Simulation.slice_history(20..220//40)
    |> Enum.zip(Enum.to_list(20..220//40))
    |> Enum.reduce(0, &(Tuple.product(&1) + &2))
  end

  @spec part2 :: [String.t()]
  def part2, do: Simulation.render(setup())

  @spec setup(0 | 1 | 2) :: simulation()
  def setup(file \\ 0),
    do: Simulation.run(Simulation.new(), Input.parse(file))
end
