defmodule Parser do
  def call(filename) do
    filename
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_string/1)
  end

  def parse_string(string) do
    string
    |> String.split(": ", trim: true)
  end
end

defmodule OperandMatcher do
  @plus_operator "+"
  @mul_operator "*"
  @concat_operator "||"

  @possbile_operators [@plus_operator, @mul_operator, @concat_operator]

  def call(parsed_input) do
    parsed_input
    |> start_calculations()
  end

  defp start_calculations(parsed_input) do
    # IO.inspect(parsed_input)

    sums =
      parsed_input
      |> Enum.map(&try_calculate_sum/1)
      # |> IO.inspect(label: "SUMS")
      |> Enum.reject(&(&1 == []))
      |> Enum.map(fn row ->
        res = hd(row)
        # IO.inspect(res)
        sum = res |> Tuple.to_list() |> Enum.at(0)
        # IO.inspect(sum)
        sum
      end)
  end

  defp try_calculate_sum([sum | operands]) do
    parsed_operands =
      operands
      |> Enum.flat_map(&String.split(&1, " ", trim: true))
      |> Enum.map(&String.to_integer/1)

    parsed_sum = String.to_integer(sum)

    operators_count = length(parsed_operands) - 1
    total_possible_operators_count = length(@possbile_operators)
    total_cycles_needed = total_possible_operators_count ** operators_count - 1

    res = do_calculations(parsed_sum, parsed_operands, operators_count, total_cycles_needed)
    res
  end

  defp do_calculations(sum, operands, operators_count, total_cycles_needed) do
    for i <- 0..total_cycles_needed,
        current_operators = get_operators_combination(operators_count, i),
        new_sum = evaluate(Enum.reverse(operands), current_operators),
        new_sum == sum do
      # IO.inspect({new_sum, sum})
      {new_sum, current_operators}
    end
  end

  defp get_operators_combination(size, number) do
    0..(size - 1)
    |> Enum.reduce(List.duplicate("+", size), fn position, acc ->
      first_bit = Bitwise.band(number, Bitwise.bsl(1, position * 2)) > 0
      second_bit = Bitwise.band(number, Bitwise.bsl(1, position * 2 + 1)) > 0

      operator =
        case {first_bit, second_bit} do
          {false, false} -> "+"
          {true, false} -> "*"
          {false, true} -> "||"
          {true, true} -> "+"
        end

      List.replace_at(acc, position, operator)
    end)
  end

  defp evaluate([num | []], _ops), do: num

  defp evaluate([num1, num2 | rest], [op | ops]) do
    # IO.inspect({num1, num2, rest, op, ops}, label: "EVAL")

    res =
      case op do
        "+" ->
          num1 + evaluate([num2 | rest], ops)

        "*" ->
          num1 * evaluate([num2 | rest], ops)

        "||" ->
          # Direct string interpolation
          combined = String.to_integer("#{evaluate([num2 | rest], ops)}#{num1}")
      end

    # IO.inspect(res, label: "RES")
    res
  end

  defp at(list, index) do
    list
    |> Enum.at(index)
  end
end

result =
  "lib/day7/day7input.txt"
  |> Parser.call()
  |> OperandMatcher.call()

result
|> Enum.uniq()
|> Enum.sum()
|> IO.inspect(label: "Result")
