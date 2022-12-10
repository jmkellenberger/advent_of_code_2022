defmodule AdventOfCode.Day9.Rope do
  alias AdventOfCode.Day9.Point

  @enforce_keys [:position, :child, :history]
  defstruct [:position, :child, :history]

  @opaque t :: %__MODULE__{
            position: Point.t(),
            child: nil | t(),
            history: MapSet.t(Point.t())
          }

  @spec new(pos_integer) :: t()
  def new(length) when length > 0,
    do: add_children(new(), length - 1)

  @start Point.new(0, 0)
  @spec new :: t()
  defp new,
    do: %__MODULE__{
      position: @start,
      child: nil,
      history: MapSet.new([@start])
    }

  @spec add_children(t(), non_neg_integer) :: t()
  defp add_children(%__MODULE__{} = rope, 0), do: rope

  defp add_children(%__MODULE__{} = rope, length) do
    %__MODULE__{rope | child: add_children(new(), length - 1)}
  end

  @spec tail_history(t()) :: MapSet.t()
  def tail_history(rope), do: tail(rope).history

  @spec tail(t()) :: t()
  defp tail(%__MODULE__{child: nil} = rope), do: rope
  defp tail(rope), do: tail(rope.child)

  @spec update_history(t()) :: t()
  defp update_history(%__MODULE__{position: pos, history: history} = rope) do
    %__MODULE__{rope | history: MapSet.put(history, pos)}
  end

  @spec make_move(t, Day9.cmd()) :: t
  def make_move(rope, cmd) do
    rope
    |> move(cmd)
    |> update_history()
    |> update_child()
  end

  @offsets [
    up: Point.new(0, 1),
    down: Point.new(0, -1),
    right: Point.new(1, 0),
    left: Point.new(-1, 0),
    up_right: Point.new(1, 1),
    up_left: Point.new(-1, 1),
    down_right: Point.new(1, -1),
    down_left: Point.new(-1, -1)
  ]

  @spec move(t, Day9.cmd()) :: t
  defp move(%{position: pos} = rope, cmd),
    do: %__MODULE__{rope | position: Point.add(pos, @offsets[cmd])}

  @spec update_child(t) :: t
  defp update_child(%__MODULE__{child: nil} = rope), do: rope

  defp update_child(%__MODULE__{} = rope) do
    case touching?(rope) do
      true ->
        rope

      false ->
        move_child(rope)
    end
  end

  @spec touching?(t) :: boolean
  defp touching?(%__MODULE__{position: pos, child: child}) do
    pos == child.position or
      Point.neighbor?(pos, child.position)
  end

  @spec move_child(Rope.t()) :: t()
  def move_child(rope) do
    %__MODULE__{rope | child: make_move(rope.child, tail_cmd(rope))}
  end

  @directions %{
    Point.new(0, 2) => :up,
    Point.new(0, -2) => :down,
    Point.new(2, 0) => :right,
    Point.new(-2, 0) => :left,
    Point.new(1, 2) => :up_right,
    Point.new(1, -2) => :down_right,
    Point.new(2, 1) => :up_right,
    Point.new(2, -1) => :down_right,
    Point.new(-1, 2) => :up_left,
    Point.new(-1, -2) => :down_left,
    Point.new(-2, 1) => :up_left,
    Point.new(-2, -1) => :down_left,
    Point.new(2, 2) => :up_right,
    Point.new(-2, -2) => :down_left,
    Point.new(-2, 2) => :up_left,
    Point.new(2, -2) => :down_right
  }
  @spec tail_cmd(t) :: Day9.cmd()
  defp tail_cmd(%__MODULE__{position: pos, child: child}),
    do: Map.get(@directions, Point.subtract(pos, child.position))
end
