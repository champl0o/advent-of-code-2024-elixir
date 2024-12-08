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
  def call(parsed_input) do
    parsed_input
    |> start_calculations()
  end

  defp start_calculations(parsed_input) do
    sums =
      parsed_input
      |> Enum.map(&try_calculate_sum/1)
      |> Enum.reject(&(&1 == []))
      |> Enum.map(fn row ->
        res = hd(row)
        sum = res |> Tuple.to_list() |> Enum.at(0)
        sum
      end)
  end

  defp try_calculate_sum([sum | operands]) do
    parsed_operands =
      operands
      |> Enum.flat_map(&String.split(&1, " ", trim: true))
      |> Enum.map(&String.to_integer/1)

    parsed_sum = String.to_integer(sum)

    results =
      calculate(parsed_operands, nil)
      |> List.flatten()

    for result <- results,
        result == parsed_sum do
      # Keep the same return format for compatibility
      {result, nil}
    end
  end

  defp calculate([], acc), do: [acc]

  defp calculate([num | rest], nil) do
    calculate(rest, num)
  end

  defp calculate([num | rest], acc) do
    [
      calculate(rest, acc + num),
      calculate(rest, acc * num),
      calculate(rest, String.to_integer("#{acc}#{num}"))
    ]
  end
end

result =
  "lib/day7/day7input.txt"
  |> Parser.call()
  |> OperandMatcher.call()

result
|> Enum.sum()
|> IO.inspect(label: "Result")
