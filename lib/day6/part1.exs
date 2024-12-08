defmodule Parser do
  def call(filename) do
    filename
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))
  end
end

defmodule MovementDetector do
  @pattern_up "^"
  @pattern_right ">"
  @pattern_down "v"
  @pattern_left "<"

  @patterns [@pattern_up, @pattern_right, @pattern_down, @pattern_left]

  @dot_pattern "."
  @obstacle_pattern "#"

  def call(grid) do
    grid
    |> find_index_of_guard()
    |> start_movement()
    |> count_uniq_visited()
    |> IO.inspect()
  end

  defp find_index_of_guard(grid) do
    grid
    |> Enum.with_index()
    |> Enum.find_value(fn {row, x} ->
      row
      |> Enum.with_index()
      |> Enum.find_value(fn {cell, y} ->
        if cell in @patterns, do: {grid, x, y, cell}
      end)
    end)
  end

  defp start_movement({grid, x, y, movement_direction}) do
    {coords, _} = get_movement_direction_coordinates(movement_direction)

    move([], grid, {x, y}, coords, movement_direction)
  end

  defp get_movement_direction_coordinates(direction) do
    coords =
      case direction do
        @pattern_up -> {-1, 0}
        @pattern_down -> {1, 0}
        @pattern_left -> {0, -1}
        @pattern_right -> {0, 1}
      end

    {coords, direction}
  end

  defp move(acc, grid, {x, y}, {dx, dy}, direction) when x + dx < 0 or y + dy < 0 do
    {:ok, acc}
  end

  defp move(acc, grid, {x, y}, {dx, dy}, direction) when x + dx >= length(grid) do
    {:ok, acc}
  end

  defp move(acc, grid, {x, y}, {dx, dy}, movement_direction) do
    new_x = x + dx
    new_y = y + dy

    row = Enum.at(grid, new_x)
    cell = Enum.at(row, new_y)

    head = {new_x, new_y, cell}

    case cell do
      nil ->
        IO.puts("End of the grid")

      @obstacle_pattern ->
        rotate_movement_direction(movement_direction)
        |> get_movement_direction_coordinates()
        |> then(fn {coords, direction} -> move(acc, grid, {x, y}, coords, direction) end)

      @dot_pattern ->
        [head | acc] |> move(grid, {new_x, new_y}, {dx, dy}, movement_direction)

      _ ->
        move(acc, grid, {new_x, new_y}, {dx, dy}, movement_direction)
    end
  end

  defp rotate_movement_direction(direction) do
    index = Enum.find_index(@patterns, &(&1 == direction))
    IO.inspect(Enum.at(@patterns, rem(index + 1, length(@patterns))))
    Enum.at(@patterns, rem(index + 1, length(@patterns)))
  end

  defp count_uniq_visited({_, list}) do
    IO.inspect(list)

    Enum.uniq_by(list, fn {x, y, _value} -> {x, y} end)
    |> Enum.filter(fn {_, _, value} -> value != @obstacle_pattern end)
    |> length()
    # Add the starting point
    |> Kernel.+(1)
  end
end

"lib/day6/day6input.txt"
|> Parser.call()
|> MovementDetector.call()
