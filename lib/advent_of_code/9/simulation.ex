defmodule AdventOfCode.Day9.Simulation do
  alias AdventOfCode.Day9.Rope

  @enforce_keys [:cmds, :rope]
  defstruct [:cmds, :rope]

  @type t :: %__MODULE__{
          cmds: [Day9.cmd()],
          rope: Day9.rope()
        }

  @spec new([Day9.cmd()], Day9.rope()) :: t()
  def new(cmds, rope_size),
    do: %__MODULE__{cmds: cmds, rope: Rope.new(rope_size)}

  @spec run(t) :: non_neg_integer
  def run(%__MODULE__{cmds: [], rope: rope}),
    do: Rope.tail_history(rope) |> MapSet.size()

  def run(%__MODULE__{cmds: [next | rest], rope: rope} = sim) do
    sim
    |> Map.put(:cmds, rest)
    |> Map.put(:rope, Rope.make_move(rope, next))
    |> run()
  end
end
