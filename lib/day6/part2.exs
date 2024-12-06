defmodule Parser do
  def call(filename) do
    filename
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))
  end
end

defmodule MovementDetector do
  @patterns %{
    "^" => {-1, 0},
    ">" => {0, 1},
    "v" => {1, 0},
    "<" => {0, -1}
  }

  @pattern_order ["^", ">", "v", "<"]

  @dot_pattern "."
  @obstacle_pattern "#"

  def call(grid) do
    with {:ok, guard_info} <- find_guard(grid) do
      guard_info
      |> start_movement()
      |> IO.inspect(label: "Final Result")
    else
      nil ->
        {:error, :no_guard_found}
    end
  end

  defp find_guard(grid) do
    grid
    |> Enum.with_index()
    |> Enum.find_value(fn {row, x} ->
      row
      |> Enum.with_index()
      |> Enum.find_value(fn {cell, y} ->
        if cell in @pattern_order, do: {:ok, {grid, x, y, cell}}
      end)
    end)
  end

  defp start_movement({grid, x, y, movement_direction}) do
    coords = @patterns[movement_direction]

    move([], grid, {x, y}, coords, movement_direction, [])
  end

  defp move(acc, grid, {x, y}, {dx, dy}, _direction, loop_acc)
       when x + dx < 0 or y + dy < 0 or x + dx >= length(grid) do
    {:ok, acc, loop_acc}
  end

  defp move(acc, grid, {x, y}, {dx, dy}, direction, loop_acc) do
    IO.inspect({x, y}, label: "Current position")
    new_pos = {new_x, new_y} = {x + dx, y + dy}
    IO.inspect(new_pos, label: "New Position")

    with {:ok, cell} <- get_cell(grid, new_x, new_y) do
      IO.inspect(cell, label: "Current Cell")
      handle_cell(acc, grid, new_pos, {dx, dy}, cell, direction, loop_acc)
    else
      _ ->
        {:ok, acc, loop_acc}
    end
  end

  defp get_cell(grid, x, y) do
    case Enum.at(grid, x) do
      nil -> :error
      row -> {:ok, Enum.at(row, y)}
    end
  end

  defp handle_cell(acc, grid, {x1, y1}, {dx, dy}, @dot_pattern, direction, loop_acc) do
    move(acc, grid, {x1, y1}, {dx, dy}, direction, loop_acc)
  end

  defp handle_cell(acc, grid, {x1, y1}, {dx, dy}, @obstacle_pattern, direction, loop_acc) do
    IO.inspect({x1, y1}, label: "Obstacle position")
    IO.inspect(direction, label: "Current direction")
    previous_position = {x1 - dx, y1 - dy}
    new_direction = rotate_movement_direction(direction)
    new_coords = @patterns[new_direction]

    arr_length = length(acc)
    IO.inspect(arr_length, label: "Array Length")

    if arr_length >= 3 do
      IO.inspect(previous_position, label: "Current position")
      IO.inspect({dx, dy}, label: "Direction")

      is_loop? = test_loop(acc, grid, {x1, y1}, {dx, dy}, direction)
      IO.inspect(is_loop?, label: "Is Loop?")

      if is_loop? == true do
        [{x1, y1, "#"} | loop_acc]
      end
    end

    IO.inspect(acc, label: "Accumulator")

    move(
      [{x1, y1, @obstacle_pattern} | acc],
      grid,
      previous_position,
      new_coords,
      new_direction,
      loop_acc
    )
  end

  defp handle_cell(acc, grid, {x1, y1}, {dx, dy}, _, direction, loop_acc) do
    move(acc, grid, {x1, y1}, {dx, dy}, direction, loop_acc)
  end

  defp rotate_movement_direction(direction) do
    index = Enum.find_index(@pattern_order, &(&1 == direction))
    IO.inspect(Enum.at(@pattern_order, rem(index + 1, length(@pattern_order))))
    Enum.at(@pattern_order, rem(index + 1, length(@pattern_order)))
  end

  defp test_loop(new_acc, grid, {x, y}, new_pos, movement_direction) do
    case test_loop_iterations(new_acc, grid, new_pos, movement_direction, 1) do
      {:cycle_found, _grid} ->
        IO.puts("=== Loop Found! ===")
        true

      {:no_cycle, _grid} ->
        IO.puts("=== No Loop Found ===")
        false

      other ->
        IO.puts("=== Unexpected Result ===")
        IO.inspect(other)
    end
  end

  defp test_loop_iterations(acc, grid, coords, direction, iteration) do
    if iteration < 50 do
      IO.inspect(iteration, label: "Iteration")
      new_x = elem(coords, 0)
      new_y = elem(coords, 1)
      value = Enum.find([new_x, new_y], &(&1 != 0))

      final_destination = Enum.at(acc, 2)
      last_obstacle = Enum.at(acc, 0)

      next_direction = rotate_movement_direction(direction)
      new_coords = @patterns[next_direction]

      obstacle_x = elem(last_obstacle, 0) + value
      obstacle_y = elem(final_destination, 1) + value
      current_pos = {obstacle_x, obstacle_y}
      initial_pos = {elem(last_obstacle, 0), elem(last_obstacle, 1)}
      # IO.inspect(current_pos, label: "Current position")
      # IO.inspect(initial_pos, label: "Initial position")

      updated_grid = GridUpdater.replace_at(grid, obstacle_x, obstacle_y, @obstacle_pattern)

      res =
        if current_pos == initial_pos do
          # IO.puts("=== Complete Loop Found! ===")
          {:cycle_found, updated_grid}
        else
          # IO.puts("=== No Complete Loop ===")
          {:no_cycle, grid}
        end

      case res do
        {:cycle_found, _} -> res
        {:no_cycle, _} -> test_loop_iterations(acc, grid, new_coords, direction, iteration + 1)
      end
    else
      {:no_cycle, grid}
    end
  end
end

defmodule GridUpdater do
  def replace_at(grid, x, y, new_value) do
    List.update_at(grid, x, fn row ->
      List.update_at(row, y, fn _current_value -> new_value end)
    end)
  end
end

"lib/day6/experimental_input.txt"
|> Parser.call()
|> MovementDetector.call()
