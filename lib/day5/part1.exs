defmodule Parser do
  def call(filename) do
    [rules, pages] =
      filename
      |> File.read!()
      |> String.split("\n\n", trim: true)

    {parse_string(rules), parse_string(pages)}
  end

  def parse_string(string) do
    string
    |> String.split("\n", trim: true)
  end
end

defmodule RuleParser do
  def call(rules) do
    rules
    |> Enum.map(&parse_rule/1)
  end

  defp parse_rule(rule) do
    rule
    |> String.split("|", trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end

defmodule PageParser do
  def call(pages) do
    pages
    |> Enum.map(&parse_page/1)
  end

  defp parse_page(page) do
    page
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end

defmodule RuleApplier do
  def call(parsed_rules, pages) do
    pages
    |> Enum.reduce([], fn page, acc ->
      case apply_rules([], parsed_rules, page) do
        {:error, _} -> acc
        {:ok, _} -> [page | acc]
      end
    end)
    |> IO.inspect()
  end

  defp apply_rules(acc, rules, page) do
    try do
      rules
      |> Enum.reduce_while(acc, fn rule, acc ->
        case apply_rule(rule, page) do
          {:ok, _} -> {:cont, acc}
          {:error, _} -> throw(:error)
          _ -> {:cont, acc}
        end
      end)

      {:ok, page}
    catch
      :error -> {:error, nil}
    end
  end

  defp apply_rule(rule, page) do
    [a, b] = rule

    index_a = Enum.find_index(page, &(&1 == a))
    index_b = Enum.find_index(page, &(&1 == b))

    case {index_a, index_b} do
      {a, b} when is_integer(a) and is_integer(b) ->
        if a < b do
          {:ok, [a, b]}
        else
          {:error, [a, b]}
        end

      _ ->
        {:skip, nil}
    end
  end
end

defmodule ArrayMiddleSumCalculator do
  def call(pages_with_applied_rules) do
    pages_with_applied_rules
    |> Enum.map(&find_middle_odd/1)
    |> Enum.sum()
  end

  def find_middle_odd(list) do
    middle_index = div(length(list), 2)
    Enum.at(list, middle_index)
  end
end

{rules, pages} =
  "lib/day5/experimental_input.txt"
  |> Parser.call()

parsed_rules = RuleParser.call(rules)
parsed_pages = PageParser.call(pages)
pages_with_applied_rules = RuleApplier.call(parsed_rules, parsed_pages)

ArrayMiddleSumCalculator.call(pages_with_applied_rules)
|> IO.inspect()
