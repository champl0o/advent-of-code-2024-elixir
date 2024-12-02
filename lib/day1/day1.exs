defmodule Parser do
  def parse_file_into_two_arrays(filename) do
    {arr1, arr2} =
      filename
      |> File.read!()
      |> String.split("\n")
      |> Enum.reject(&(String.trim(&1) == ""))
      |> Enum.map(fn line ->
        [num1, num2] =
          line
          |> String.split()
          |> Enum.map(&String.to_integer/1)
        {num1, num2}
      end)
      |> Enum.unzip()

    {arr1, arr2}
  end
end

defmodule Counter do
  def count_diff(arr1, arr2) do
    total_size = Enum.count(arr1)

    Enum.map(0..(total_size - 1), fn i ->
      abs(Enum.at(arr1, i) - Enum.at(arr2, i))
    end)
    |> Enum.sum()
  end

  def count_same(arr1, arr2) do
    Enum.map(arr1, fn num1 ->
      Enum.count(arr2, fn num2 ->
        num1 == num2
      end)
      |> (fn x -> x * num1 end).()
    end)
    |> Enum.sum()
  end
end


{arr1, arr2} = Parser.parse_file_into_two_arrays("lib/day1/input.txt")
sorted_arr1 = Enum.sort(arr1)
sorted_arr2 = Enum.sort(arr2)

total_size = Enum.count(sorted_arr1)

IO.inspect(sorted_arr1)
IO.inspect(sorted_arr2)
IO.inspect(total_size)

Counter.count_diff(sorted_arr1, sorted_arr2)
|> IO.inspect()

# END of task 1

# Task 2
Counter.count_same(sorted_arr1, sorted_arr2)
|> IO.inspect()


