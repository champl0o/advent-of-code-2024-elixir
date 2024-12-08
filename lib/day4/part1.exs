defmodule Parser do
  def call(filename) do
    filename
    |> File.read!()
    |> String.split("\n", trim: true)
  end
end

defmodule Scanner do
  @pattern ["X", "M", "A", "S"]
  @rotations 0..3

  def call(list) do
    list
    |> to_grid()
    |> count_all_patterns()
  end

  defp to_grid(list) do
    Enum.map(list, &String.graphemes/1)
  end

  defp count_all_patterns(initial_grid) do
    @rotations
    |> Enum.reduce({0, initial_grid}, &count_and_rotate/2)
    |> elem(0)
  end

  defp count_and_rotate(_, {total, grid}) do
    count = count_patterns(grid)
    {total + count, rotate90(grid)}
  end

  defp count_patterns(grid) do
    count_horizontal(grid) + count_diagonal(grid)
  end

  defp count_horizontal(grid) do
    pattern_length = length(@pattern)

    grid
    |> Enum.flat_map(fn row ->
      0..(length(row) - pattern_length)
      |> Enum.map(&Enum.slice(row, &1, pattern_length))
    end)
    |> Enum.count(&pattern_matches?/1)
  end

  defp count_diagonal(grid) do
    pattern_length = length(@pattern)
    grid_size = length(grid)

    for i <- 0..(grid_size - pattern_length),
        j <- 0..(grid_size - pattern_length) do
      get_diagonal(grid, i, j, pattern_length)
    end
    |> Enum.count(&pattern_matches?/1)
  end

  defp get_diagonal(grid, row, col, length) do
    for k <- 0..(length - 1) do
      grid |> Enum.at(row + k) |> Enum.at(col + k)
    end
  end

  defp pattern_matches?(chars) do
    Enum.zip(@pattern, chars)
    |> Enum.all?(fn {a, b} -> a == b end)
  end

  defp rotate90(grid) do
    grid_size = length(grid)

    for j <- 0..(grid_size - 1) do
      for i <- (grid_size - 1)..0 do
        grid |> Enum.at(i) |> Enum.at(j)
      end
    end
  end
end

"lib/day4/day4input.txt"
|> Parser.call()
|> Scanner.call()
|> IO.inspect()
