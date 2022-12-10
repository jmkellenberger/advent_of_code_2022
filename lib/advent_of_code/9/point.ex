defmodule AdventOfCode.Day9.Point do
  @enforce_keys [:col, :row]
  defstruct [:col, :row]

  @type t :: %__MODULE__{
          col: integer(),
          row: integer()
        }

  @spec new({integer, integer}) :: t()
  def new({col, row}), do: new(col, row)

  @spec new(integer(), integer()) :: t
  def new(col, row), do: %__MODULE__{col: col, row: row}

  @spec add(t(), t()) :: t()
  def add(%__MODULE__{} = p1, %__MODULE__{} = p2),
    do: new(p1.col + p2.col, p1.row + p2.row)

  @spec subtract(t(), t()) :: t()
  def subtract(%__MODULE__{} = p1, %__MODULE__{} = p2),
    do: new(p1.col - p2.col, p1.row - p2.row)

  @neighbors [
    {1, 0},
    {0, 1},
    {0, -1},
    {-1, 0},
    {1, 1},
    {-1, 1},
    {-1, -1},
    {1, -1}
  ]
  @spec neighbor?(t, t) :: boolean
  def neighbor?(p1, p2), do: p1 in neighbors(p2)

  @spec neighbors(t) :: [t]
  def neighbors(point),
    do: Enum.map(@neighbors, &add(point, new(&1)))
end
