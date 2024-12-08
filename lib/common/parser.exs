defmodule Common.Parser do
  def call(filename) do
    filename
    |> File.read!()
    |> String.split("\n", trim: true)
  end
end
