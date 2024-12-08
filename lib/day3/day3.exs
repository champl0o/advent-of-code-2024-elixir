defmodule Scanner do
  def scan(filename) do
    filename
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&scan_line/1)
    |> List.flatten()
    |> process_instructions()
    |> extract_numbers()
    |> Enum.sum()
  end

  defp scan_line(line) do
    Regex.scan(~r/(mul\(\d{1,3},\d{1,3}\)|do\(\)|don't\(\))/, line)
    |> Enum.map(fn [match | _] -> match end)
  end

  defp process_instructions(instructions) do
    {result, _} =
      Enum.reduce(instructions, {[], :enabled}, fn instruction, {acc, state} ->
        case {instruction, state} do
          {"do()" <> _, _} -> {acc, :enabled}
          {"don't()" <> _, _} -> {acc, :disabled}
          {"mul" <> _ = mul, :enabled} -> {[mul | acc], state}
          _ -> {acc, state}
        end
      end)

    Enum.reverse(result)
  end

  defp extract_numbers(muls) do
    Enum.map(muls, fn mul ->
      [_, n1, n2] = Regex.run(~r/mul\((\d+),(\d+)\)/, mul)
      String.to_integer(n1) * String.to_integer(n2)
    end)
  end
end

"lib/day3/day3_input.txt"
|> Scanner.scan()
|> IO.inspect()
