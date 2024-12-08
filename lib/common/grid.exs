defmodule Common.Grid do
  def at(grid, row, col) do
    grid
    |> Enum.at(row, [])
    |> Enum.at(col)
  end
end
