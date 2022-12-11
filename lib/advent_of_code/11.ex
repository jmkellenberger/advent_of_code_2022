defmodule AdventOfCode.Day11 do
  defmodule Input do
    alias AdventOfCode.Day11.Monkey

    @spec parse(boolean()) :: Day11.monkeys()
    def parse(stressed) do
      File.read!("assets/11.txt")
      |> String.split("\n\n", trim: true)
      |> build_monkeys(stressed)
    end

    @spec build_monkeys([String.t()], boolean) :: Day11.monkeys()
    def build_monkeys(data, stressed) do
      data
      |> Enum.map(
        &(String.split(&1, "\n", trim: true)
          |> Enum.map(fn line -> String.trim(line) end)
          |> build_monkey()
          |> Map.put(:stressed, stressed))
      )
      |> calculate_lcm()
      |> Enum.reduce(%{}, &Map.put(&2, &1.id, &1))
    end

    @spec build_monkey([String.t()]) :: Monkey.t()
    def build_monkey(["Monkey " <> id | rest]) do
      id = String.replace(id, ":", "") |> String.to_integer()
      build_monkey(rest, %{id: id})
    end

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
             "If false: throw to monkey " <> m2 | _
           ],
           attrs
         ) do
      [div, m1, m2 | _] = [div, m1, m2] |> Enum.map(&String.to_integer/1)

      attrs =
        attrs
        |> Map.put(:lcm, div)
        |> Map.put(:test, fn old ->
          if rem(old, div) == 0 do
            m1
          else
            m2
          end
        end)

      struct(Monkey, attrs)
    end

    defp calculate_lcm(monkeys) do
      divisors = for monkey <- monkeys, do: monkey.lcm
      lcm = Enum.reduce(divisors, &lcm/2)
      Enum.map(monkeys, &Map.put(&1, :lcm, lcm))
    end

    defp gcd(a, 0), do: a
    defp gcd(0, b), do: b
    defp gcd(a, b), do: gcd(b, rem(a, b))
    defp lcm(0, 0), do: 0
    defp lcm(a, b), do: div(a * b, gcd(a, b))
  end

  defmodule Monkey do
    @enforce_keys [:id, :op, :test, :lcm, :items]
    defstruct [
      :id,
      :op,
      :test,
      :items,
      :stressed,
      :lcm,
      turns: 0
    ]

    @type t :: %__MODULE__{
            id: integer(),
            op: fun(),
            test: fun(),
            lcm: integer(),
            items: [integer()]
          }

    @type result :: {integer(), integer()}

    @spec inspect_items(t) :: {t, [result]}
    def inspect_items(
          %__MODULE__{items: items, op: op, test: test, turns: t, lcm: lcm} =
            monkey
        ) do
      results =
        case monkey.stressed do
          false ->
            Enum.map(items, fn item ->
              new_item = div(op.(item), 3)
              {test.(new_item), new_item}
            end)

          true ->
            Enum.map(items, fn item ->
              new_item = rem(op.(item), lcm)
              {test.(new_item), new_item}
            end)
        end

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

  @spec part1 :: number
  def part1 do
    setup(false)
    |> MonkeyBusiness.start(20)
    |> MonkeyBusiness.get_level()
  end

  @spec part2 :: number
  def part2 do
    setup(true)
    |> MonkeyBusiness.start(10_000)
    |> MonkeyBusiness.get_level()
  end

  @spec setup(boolean) :: MonkeyBusiness.t()
  def setup(stressed) do
    Input.parse(stressed)
  end
end
