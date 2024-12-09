defmodule Parser do
  def call(filename) do
    filename
    |> File.read!()
    |> String.split("\n", trim: true)
  end
end

defmodule StringReplacer do
  @dot_char "."

  def call(input) do
    data =
      input
      |> Enum.map(&String.graphemes/1)
      |> Enum.flat_map(fn row ->
        row
        |> Enum.with_index()
        |> Enum.map(&replace_char/1)
      end)
      |> List.flatten()
      |> IO.inspect()

    input_length = length(data)

    0..input_length
    |> Enum.reduce(data, fn index, acc ->
      if index < input_length do
        current_value = Enum.at(acc, index)

        if current_value == @dot_char do
          # Find next non-dot value after current position
          case find_next_number(acc, index + 1) do
            nil ->
              acc

            {number, number_index} ->
              # Swap dot with the found number
              acc
              |> List.replace_at(index, number)
              |> List.replace_at(number_index, @dot_char)
          end
        else
          acc
        end
      else
        acc
      end
    end)
    |> Enum.filter(fn num ->
      num != @dot_char
    end)
    |> Enum.with_index()
    |> Enum.map(fn {num, index} ->
      num * index
    end)
    |> Enum.sum()
  end

  defp replace_char({char, index}) when rem(index, 2) == 0,
    do: List.duplicate(round(index / 2), String.to_integer(char))

  defp replace_char({char, _index}), do: List.duplicate(".", String.to_integer(char))

  defp find_next_number(list, start_index) do
    list
    |> Enum.drop(start_index)
    |> Enum.with_index(start_index)
    |> Enum.reverse()
    |> Enum.find(fn {value, _idx} -> value != @dot_char end)
  end
end

"lib/day9/experimental_input.txt"
|> Parser.call()
|> StringReplacer.call()
|> IO.inspect()
