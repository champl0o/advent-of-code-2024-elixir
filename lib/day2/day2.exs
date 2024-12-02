defmodule SafetyChecker do
  def parse_file(filename) do
    filename
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split()
      |> Enum.map(&String.to_integer/1)
    end)
  end

  def check_sequence(sequence) do
    if is_valid?(sequence) do
      {:ok, sequence}
    else
      0..(length(sequence) - 1)
      |> Enum.find_value(fn idx ->
        new_seq = List.delete_at(sequence, idx)
        if is_valid?(new_seq), do: {:fixable, sequence, idx}
      end) || {:invalid, sequence}
    end
  end

  defp is_valid?(sequence) do
    pairs = Enum.zip(sequence, tl(sequence))

    diffs_ok =
      Enum.all?(pairs, fn {a, b} ->
        diff = abs(a - b)
        diff >= 1 and diff <= 3
      end)

    increasing = Enum.all?(pairs, fn {a, b} -> a < b end)
    decreasing = Enum.all?(pairs, fn {a, b} -> a > b end)

    diffs_ok and (increasing or decreasing)
  end
end

# Usage
"lib/day2/day2.txt"
|> SafetyChecker.parse_file()
|> Enum.map(&SafetyChecker.check_sequence/1)
|> Enum.count(fn
  {:ok, _sequence} -> true
  {:fixable, _, _} -> true
  _ -> false
end)
|> IO.inspect()
