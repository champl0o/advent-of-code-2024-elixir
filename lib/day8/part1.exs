defmodule Parser do
  def call(filename) do
    filename
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes/1)
  end
end

defmodule AntinodeLocator do
  @dot_pattern "."

  def call(grid) do
    grid
    |> find_anti_node_placement()
  end

  defp find_anti_node_placement(grid) do
    grid
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, row_idx} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn {cell, col_idx} ->
        find_combinations(grid, cell, {row_idx, col_idx})
      end)
      |> Enum.reject(&(&1 == nil))
    end)
    |> calculate_anti_node_placements([], grid)
  end

  defp find_combinations(_grid, @dot_pattern, _) do
    nil
  end

  defp find_combinations(grid, first_cell, {row_idx, col_idx}) do
    grid
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, new_row_idx} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn {new_cell, new_col_idx} ->
        if first_cell == new_cell and {row_idx, col_idx} != {new_row_idx, new_col_idx} do
          {row_idx, col_idx, new_row_idx, new_col_idx}
        end
      end)
      |> Enum.reject(&(&1 == nil))
      |> Enum.reject(&(&1 == {row_idx, col_idx}))
    end)
  end

  def calculate_anti_node_placements(antenna_coords_grid, acc, grid) do
    anti_node_coords =
      antenna_coords_grid
      |> Enum.flat_map(fn row ->
        row
        |> Enum.map(fn {row_idx, col_idx, new_row_idx, new_col_idx} ->
          diff_x = abs(row_idx - new_row_idx)
          diff_y = abs(col_idx - new_col_idx)

          diff_x = if row_idx > new_row_idx, do: -diff_x, else: diff_x
          diff_y = if col_idx > new_col_idx, do: -diff_y, else: diff_y

          x1_pos = row_idx - diff_x
          y1_pos = col_idx - diff_y

          res1 = can_put_anti_node?(grid, {x1_pos, y1_pos}, {diff_x, diff_y}, [])

          if res1 == [false], do: [], else: [{row_idx, col_idx} | res1]
        end)
      end)
      |> Enum.reject(&(&1 == []))
      |> List.flatten()
      |> Enum.uniq()
      |> Enum.sort()
      |> IO.inspect()
      |> Enum.count()
      |> IO.inspect()
  end

  def can_put_anti_node?(grid, {x, y}, {diff_x, diff_y}, acc) when x >= 0 and y >= 0 do
    case Enum.at(grid, x) do
      nil ->
        acc

      row ->
        case Enum.at(row, y) do
          nil ->
            acc

          cell ->
            x1_pos = x - diff_x
            y1_pos = y - diff_y
            [{x, y} | can_put_anti_node?(grid, {x1_pos, y1_pos}, {diff_x, diff_y}, acc)]
        end
    end
  end

  # Add a catch-all clause for negative coordinates
  def can_put_anti_node?(_, {x, y}, _, acc) when x < 0 or y < 0, do: acc
end

"lib/day8/day8input.txt"
|> Parser.call()
|> IO.inspect()
|> AntinodeLocator.call()
