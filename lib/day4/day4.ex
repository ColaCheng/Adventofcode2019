defmodule Day4 do
  @input "356261-846303"

  def part1(input \\ @input) do
    [from, to] = read_data(input)

    Enum.reduce(from..to, 0, fn num, count ->
      (is_match_rule1?(num) && count + 1) || count
    end)
  end

  def part2(input \\ @input) do
    [from, to] = read_data(input)

    Enum.reduce(from..to, 0, fn num, count ->
      (is_match_rule2?(num) && count + 1) || count
    end)
  end

  defp read_data(input) do
    String.split(input, "-") |> Enum.map(&String.to_integer/1)
  end

  defp is_match_rule1?(num) do
    <<digit::binary-size(1), res::binary>> = Integer.to_string(num)

    case traverse_string1(res, digit, {false, false}) do
      {true, true} -> true
      _ -> false
    end
  end

  defp traverse_string1(<<>>, _pre_digit, result), do: result

  defp traverse_string1(<<digit::binary-size(1), res::binary>>, digit, {_same?, _valid?}) do
    traverse_string1(res, digit, {true, true})
  end

  defp traverse_string1(<<digit::binary-size(1), res::binary>>, pre_digit, {same?, _valid?})
       when digit > pre_digit do
    traverse_string1(res, digit, {same?, true})
  end

  defp traverse_string1(_, _, _), do: {false, false}

  def is_match_rule2?(num) do
    <<digit::binary-size(1), res::binary>> = Integer.to_string(num)

    case traverse_string2(res, digit, {%{}, false}) do
      {_, false} -> false
      {same_digit_map, _} when map_size(same_digit_map) == 0 -> false
      {same_digit_map, true} -> Map.values(same_digit_map) |> Enum.any?(&(&1 == 2))
    end
  end

  defp traverse_string2(<<>>, _pre_digit, result), do: result

  defp traverse_string2(<<digit::binary-size(1), res::binary>>, digit, {same_digit_map, _}) do
    new_same_digit_map =
      case Map.get(same_digit_map, digit, 0) do
        0 -> Map.put(same_digit_map, digit, 2)
        time -> Map.put(same_digit_map, digit, time + 1)
      end

    traverse_string2(res, digit, {new_same_digit_map, true})
  end

  defp traverse_string2(<<digit::binary-size(1), res::binary>>, pre_digit, {same_digit_map, _})
       when digit > pre_digit do
    traverse_string2(res, digit, {same_digit_map, true})
  end

  defp traverse_string2(_, _, _), do: {%{}, false}
end
