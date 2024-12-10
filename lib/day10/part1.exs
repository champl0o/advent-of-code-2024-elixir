defmodule Parser do
  def call(filename) do
    filename
    |> File.read!()
    |> String.split("\n", trim: true)
  end
end

defmodule TrailFinder do
  def call(list_input) do
    list_input
    |> convert_to_grid()
    |> find_trail_head_score()
  end

  defp convert_to_grid(list_input) do
    list_input
    |> Enum.map(&String.graphemes/1)
    |> Enum.map(fn row ->
      row
      |> Enum.map(fn char ->
        case char do
          "." -> "."
          _ -> String.to_integer(char)
        end
      end)
    end)
  end

  defp find_trail_head_score(grid) do
    grid
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, row_index} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn {cell, cell_index} ->
        case cell do
          "." ->
            nil

          0 ->
            {cell, row_index, cell_index}

          _ ->
            nil
        end
      end)
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.flat_map(fn {value, x, y} ->
      IO.inspect({value, x, y})
      find_path([value], grid, {value, x, y})
    end)
    |> List.flatten()
    |> Enum.chunk_every(10)
    |> IO.inspect()
    |> length()
    |> IO.inspect()
  end

  defp find_path(
         acc,
         _grid,
         {value, value_x_index, value_y_index}
       )
       when value >= 9 do
    acc
  end

  defp find_path(acc, grid, {value, value_x_index, value_y_index}) do
    next_value = value + 1

    left = {value_x_index, value_y_index - 1}
    right = {value_x_index, value_y_index + 1}
    up = {value_x_index - 1, value_y_index}
    down = {value_x_index + 1, value_y_index}

    values = %{
      left_value: {get_value(grid, left), left},
      right_value: {get_value(grid, right), right},
      up_value: {get_value(grid, up), up},
      down_value: {get_value(grid, down), down}
    }

    Enum.filter(values, fn {_key, {value, coords}} ->
      value == next_value
    end)
    |> Enum.map(fn {key, {value, {x, y}}} ->
      find_path([value | acc], grid, {value, x, y})
    end)
  end

  def get_value(grid, {x, y}) when x >= 0 and y >= 0 do
    case Enum.at(grid, x) do
      nil -> nil
      row -> Enum.at(row, y)
    end
  end

  def get_value(_grid, _index), do: nil

  def positive?(number) when is_number(number) do
    number >= 0
  end
end

"lib/day10/day10input.txt"
|> Parser.call()
|> TrailFinder.call()
