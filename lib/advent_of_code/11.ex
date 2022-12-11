defmodule AdventOfCode.Day11 do
  defmodule Input do
    alias AdventOfCode.Day11.Monkey

    @spec parse(0 | 1) :: Day11.monkeys()
    def parse(data) do
      case(data) do
        0 -> "assets/11.txt"
        1 -> "assets/11test.txt"
      end
      |> File.read!()
      |> String.split("\n\n", trim: true)
      |> Enum.map(
        &(String.split(&1, "\n", trim: true)
          |> Enum.map(fn line -> String.trim(line) end)
          |> build_monkey())
      )
      |> Enum.reduce(%{}, &Map.put(&2, &1.id, &1))
    end

    @spec build_monkey([String.t()]) :: Monkey.t()
    def build_monkey(["Monkey " <> id | rest]) do
      id = String.replace(id, ":", "") |> String.to_integer()
      build_monkey(rest, %{id: id})
    end

    defp build_monkey([], attrs), do: struct(Monkey, attrs)

    defp build_monkey(["Starting items: " <> items | rest], attrs) do
      items =
        items
        |> String.split(", ", trim: true)
        |> Enum.map(&String.to_integer/1)

      build_monkey(rest, Map.put(attrs, :items, items))
    end

    defp build_monkey(["Operation: new = old * old" | rest], attrs) do
      build_monkey(rest, Map.put(attrs, :op, fn old -> old * old end))
    end

    defp build_monkey(["Operation: new = old + " <> num | rest], attrs) do
      num = String.to_integer(num)
      build_monkey(rest, Map.put(attrs, :op, fn old -> old + num end))
    end

    defp build_monkey(["Operation: new = old * " <> num | rest], attrs) do
      num = String.to_integer(num)
      build_monkey(rest, Map.put(attrs, :op, fn old -> old * num end))
    end

    defp build_monkey(
           [
             "Test: divisible by " <> div,
             "If true: throw to monkey " <> m1,
             "If false: throw to monkey " <> m2 | rest
           ],
           attrs
         ) do
      [div, m1, m2 | _] = [div, m1, m2] |> Enum.map(&String.to_integer/1)

      build_monkey(
        rest,
        Map.put(attrs, :test, fn old ->
          if rem(old, div) == 0 do
            m1
          else
            m2
          end
        end)
      )
    end
  end

  defmodule Monkey do
    @enforce_keys [:id, :op, :test, :items]
    defstruct [
      :id,
      :op,
      :test,
      :items,
      turns: 0
    ]

    @type t :: %__MODULE__{
            id: integer(),
            op: fun(),
            test: fun(),
            items: [integer()]
          }

    @type result :: {integer(), integer()}

    @spec new(integer(), fun(), fun(), [integer()]) ::
            AdventOfCode.Day11.Monkey.t()
    def new(id, op, test, items) do
      %__MODULE__{
        id: id,
        op: op,
        test: test,
        items: items
      }
    end

    @spec inspect_items(t) :: {t, [result]}
    def inspect_items(
          %__MODULE__{items: items, op: op, test: test, turns: t} = monkey
        ) do
      results =
        Enum.map(items, fn item ->
          new_item = div(op.(item), 3)
          {test.(new_item), new_item}
        end)

      {%{monkey | items: [], turns: t + length(items)}, results}
    end

    @spec yoink(t, integer()) :: t
    def yoink(%__MODULE__{items: items} = monkey, item) do
      %{monkey | items: items ++ [item]}
    end
  end

  defmodule MonkeyBusiness do
    @spec start(Day11.monkeys(), pos_integer()) :: Day11.monkeys()
    def start(monkeys, rounds) do
      new_round(monkeys, rounds)
    end

    @spec get_level(Day11.monkeys()) :: number
    def get_level(monkeys) do
      monkeys
      |> Map.values()
      |> Enum.map(&Map.get(&1, :turns))
      |> Enum.sort(:desc)
      |> Enum.take(2)
      |> Enum.product()
    end

    @spec new_round(Day11.monkeys(), non_neg_integer()) ::
            Day11.monkeys()
    defp new_round(monkeys, 0), do: monkeys

    defp new_round(monkeys, rounds) do
      take_turn(monkeys, 0)
      |> new_round(rounds - 1)
    end

    @spec take_turn(Monkey.t(), Day11.monkeys()) :: Day11.monkeys()
    def take_turn(monkeys, id) when id in 0..(map_size(monkeys) - 1) do
      {new_monkey, results} = Monkey.inspect_items(monkeys[id])

      monkeys
      |> Map.put(id, new_monkey)
      |> yeet(results)
      |> take_turn(id + 1)
    end

    def take_turn(monkeys, _id), do: monkeys

    @spec yeet(Day11.monkeys(), [Day11.results()]) :: Day11.monkeys()
    defp yeet(monkeys, []), do: monkeys

    defp yeet(monkeys, [{id, item} | rest]) do
      monkeys
      |> Map.put(id, Monkey.yoink(monkeys[id], item))
      |> yeet(rest)
    end
  end

  @type results :: [Monkey.result()]
  @type monkeys :: %{integer() => Monkey.t()}

  def part1 do
    setup()
    |> MonkeyBusiness.start(20)
    |> MonkeyBusiness.get_level()
  end

  def part2 do
    "TBD"
  end

  @spec setup(0 | 1) :: MonkeyBusiness.t()
  def setup(file \\ 0) do
    Input.parse(file)
  end
end
