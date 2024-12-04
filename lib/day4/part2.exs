defmodule Parser do
  def call(filename) do
    filename
    |> File.read!()
    |> String.split("\n", trim: true)
  end
end

defmodule Scanner do
  @pattern ["M", "A", "S"]
  @rotations 0..3

  def call(list) do
    list
    |> to_grid()
    |> count_all_crosses()
  end

  defp to_grid(list) do
    Enum.map(list, &String.graphemes/1)
  end

  defp count_all_crosses(initial_grid) do
    @rotations
    |> Enum.reduce({0, initial_grid}, &count_and_rotate/2)
    |> elem(0)
  end

  defp count_and_rotate(_, {total, grid}) do
    count = find_crosses(grid)
    {total + count, rotate90(grid)}
  end

  defp find_crosses(grid) do
    pattern_length = length(@pattern)
    grid_size = length(grid)

    matches =
      for i <- 0..(grid_size - pattern_length),
          j <- 0..(grid_size - pattern_length) do
        cross_matches?(grid, i, j, pattern_length)
      end

    Enum.count(matches, & &1)
  end

  defp cross_matches?(grid, row, col, length) do
    forward_diagonal = get_diagonal(grid, row, col, length)
    backward_diagonal = get_reverse_diagonal(grid, row + length - 1, col, length)

    pattern_matches?(forward_diagonal) && pattern_matches?(backward_diagonal)
  end

  defp get_diagonal(grid, row, col, length) do
    for k <- 0..(length - 1) do
      grid |> Enum.at(row + k) |> Enum.at(col + k)
    end
  end

  defp get_reverse_diagonal(grid, row, col, length) do
    for k <- 0..(length - 1) do
      grid |> Enum.at(row - k) |> Enum.at(col + k)
    end
  end

  defp pattern_matches?(chars) do
    Enum.zip(@pattern, chars)
    |> Enum.all?(fn {a, b} -> a == b end)
  end

  defp rotate90(grid) do
    grid_size = length(grid)
    half_size = div(grid_size, 2)

    for i <- 0..(half_size - 1),
        j <- i..(grid_size - i - 2),
        reduce: grid do
      acc ->
        temp = acc |> Enum.at(i) |> Enum.at(j)
        acc = put_in_grid(acc, i, j, acc |> Enum.at(j) |> Enum.at(grid_size - 1 - i))

        acc =
          put_in_grid(
            acc,
            j,
            grid_size - 1 - i,
            acc |> Enum.at(grid_size - 1 - i) |> Enum.at(grid_size - 1 - j)
          )

        acc =
          put_in_grid(
            acc,
            grid_size - 1 - i,
            grid_size - 1 - j,
            acc |> Enum.at(grid_size - 1 - j) |> Enum.at(i)
          )

        put_in_grid(acc, grid_size - 1 - j, i, temp)
    end
  end

  defp put_in_grid(grid, row, col, value) do
    List.update_at(grid, row, fn row_list ->
      List.replace_at(row_list, col, value)
    end)
  end
end

"lib/day4/day4input.txt"
|> Parser.call()
|> Scanner.call()
|> IO.inspect()
