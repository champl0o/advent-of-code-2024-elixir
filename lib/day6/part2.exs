defmodule GuardRoute do
  def find_route(start_pos, next_row, next_col, grid) do
    row_count = length(grid)
    col_count = length(hd(grid))

    visited =
      traverse_route(
        MapSet.new(),
        start_pos,
        {next_row, next_col},
        {row_count, col_count},
        grid
      )

    visited
  end

  defp traverse_route(visited, {curr_row, curr_col} = pos, {next_row, next_col}, dims, grid) do
    visited = MapSet.put(visited, pos)

    if out_of_bounds?({curr_row + next_row, curr_col + next_col}, dims) do
      visited
    else
      if obstacle_at?(grid, curr_row + next_row, curr_col + next_col) do
        traverse_route(visited, pos, {next_col, -next_row}, dims, grid)
      else
        traverse_route(
          visited,
          {curr_row + next_row, curr_col + next_col},
          {next_row, next_col},
          dims,
          grid
        )
      end
    end
  end

  def find_looped_route(start_pos, next_row, next_col, grid) do
    row_count = length(grid)
    col_count = length(hd(grid))

    check_loop(
      MapSet.new(),
      start_pos,
      {next_row, next_col},
      {row_count, col_count},
      grid
    )
  end

  defp check_loop(visited, {curr_row, curr_col}, {next_row, next_col} = movement, dims, grid) do
    state = {curr_row, curr_col, next_row, next_col}

    cond do
      MapSet.member?(visited, state) ->
        true

      out_of_bounds?({curr_row + next_row, curr_col + next_col}, dims) ->
        false

      true ->
        visited = MapSet.put(visited, state)

        if obstacle_at?(grid, curr_row + next_row, curr_col + next_col) do
          check_loop(visited, {curr_row, curr_col}, {next_col, -next_row}, dims, grid)
        else
          check_loop(visited, {curr_row + next_row, curr_col + next_col}, movement, dims, grid)
        end
    end
  end

  def part_one(input) do
    grid = parse_grid(input)
    start_pos = find_start_position(grid)
    visited = find_route(start_pos, -1, 0, grid)
    MapSet.size(visited)
  end

  def part_two(input) do
    grid = parse_grid(input)
    start_pos = find_start_position(grid)
    dims = {length(grid), length(hd(grid))}

    for row <- 0..(length(grid) - 1),
        col <- 0..(length(hd(grid)) - 1),
        IO.inspect({row, col}),
        at(grid, row, col) == ".",
        {row, col} != start_pos,
        grid_with_obstacle = put_obstacle(grid, row, col),
        find_looped_route(start_pos, -1, 0, grid_with_obstacle),
        reduce: 0 do
      acc -> acc + 1
    end
  end

  defp parse_grid(input) do
    input
    |> Enum.map(&String.graphemes/1)
  end

  defp find_start_position(grid) do
    grid
    |> Enum.with_index()
    |> Enum.find_value(fn {row, row_idx} ->
      row
      |> Enum.with_index()
      |> Enum.find_value(fn {cell, col_idx} ->
        if cell == "^", do: {row_idx, col_idx}
      end)
    end)
  end

  defp out_of_bounds?({row, col}, {row_count, col_count}) do
    row < 0 or row >= row_count or col < 0 or col >= col_count
  end

  defp obstacle_at?(grid, row, col) do
    at(grid, row, col) == "#"
  end

  defp at(grid, row, col) do
    grid
    |> Enum.at(row, [])
    |> Enum.at(col)
  end

  defp put_obstacle(grid, row, col) do
    List.update_at(grid, row, fn line ->
      List.update_at(line, col, fn _ -> "#" end)
    end)
  end
end

# Usage
input =
  File.read!("lib/day6/day6input.txt")
  |> String.split("\n", trim: true)

IO.puts("Part 1: #{GuardRoute.part_one(input)}")
{time, result} = :timer.tc(fn -> GuardRoute.part_two(input) end)
IO.puts("Part 2: #{result}")
IO.puts("Executed in #{time / 1_000_000} seconds")
