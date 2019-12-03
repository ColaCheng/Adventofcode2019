defmodule Day3 do
  @input_file "./lib/day3/input"

  def part1() do
    {coordinates1, coordinates2} = read_data()

    do_part1(coordinates1, coordinates2, [])
    |> Enum.map(&manhattan_distance/1)
    |> Enum.sort()
    |> List.first()
  end

  defp do_part1([], _, acc), do: acc
  defp do_part1([_], _, acc), do: acc
  defp do_part1(_, [], acc), do: acc
  defp do_part1(_, [_], acc), do: acc

  defp do_part1([a_p1, a_p2 | a_tail], [b_p1, b_p2 | b_tail], acc) do
    new_acc =
      case find_cross({a_p1, a_p2}, {b_p1, b_p2}) do
        {0, 0} -> acc
        {_, _} = cross -> [cross | acc]
        nil -> acc
      end

    do_part1([a_p2 | a_tail], [b_p2 | b_tail], do_part1([a_p1, a_p2], [b_p2 | b_tail], new_acc))
  end

  def part2() do
    {coordinates1, coordinates2} = read_data()

    do_part1(coordinates1, coordinates2, [])
    |> do_part2(coordinates1, coordinates2, [])
    |> Enum.sort()
    |> List.first()
  end

  defp do_part2([], _, _, acc), do: acc

  defp do_part2([cross | cross_tail], coordinates1, coordinates2, acc) do
    do_part2(cross_tail, coordinates1, coordinates2, [
      cal_steps(cross, coordinates1, 0) + cal_steps(cross, coordinates2, 0) | acc
    ])
  end

  defp cal_steps(_, [], acc), do: acc
  defp cal_steps(_, [_], acc), do: acc

  defp cal_steps({cross_x, cross_y} = cross, [{x1, y1} = p1, {x2, y2} = p2 | tail], acc) do
    case is_cross?({x1, cross_x, x2}, {y1, cross_y, y2}) do
      true -> manhattan_distance(p1, cross) + acc
      false -> cal_steps(cross, [p2 | tail], manhattan_distance(p1, p2) + acc)
    end
  end

  defp find_cross({{a_x1, a_y1}, {a_x2, a_y2}}, {{b_x1, b_y1}, {b_x2, b_y2}})
       when a_x1 == a_x2 and b_y1 == b_y2 do
    case is_cross?({b_x1, a_x1, b_x2}, {a_y1, b_y1, a_y2}) do
      true -> {a_x1, b_y1}
      false -> nil
    end
  end

  defp find_cross({{a_x1, a_y1}, {a_x2, a_y2}}, {{b_x1, b_y1}, {b_x2, b_y2}})
       when a_y1 == a_y2 and b_x1 == b_x2 do
    case is_cross?({a_x1, b_x1, a_x2}, {b_y1, a_y1, b_y2}) do
      true -> {b_x1, a_y1}
      false -> nil
    end
  end

  defp find_cross(_, _), do: nil

  defp is_cross?({x1, x2, x3}, {y1, y2, y3}) do
    distance_x = abs(x1 - x3)
    distance_y = abs(y1 - y3)

    case {abs(x1 - x2) + abs(x2 - x3), abs(y1 - y2) + abs(y2 - y3)} do
      {^distance_x, ^distance_y} -> true
      _ -> false
    end
  end

  defp traverse_path([], _position, acc), do: Enum.reverse(acc)

  defp traverse_path([h | t], position, acc) do
    new_position =
      parse(h)
      |> update_position(position)

    traverse_path(t, new_position, [new_position | acc])
  end

  defp update_position({:R, distance}, {x, y}), do: {x + distance, y}
  defp update_position({:L, distance}, {x, y}), do: {x - distance, y}
  defp update_position({:U, distance}, {x, y}), do: {x, y + distance}
  defp update_position({:D, distance}, {x, y}), do: {x, y - distance}

  defp parse(instruction) do
    <<direction::binary-size(1), distance::binary>> = instruction
    {convert_direction(direction), String.to_integer(distance)}
  end

  defp convert_direction("R"), do: :R
  defp convert_direction("L"), do: :L
  defp convert_direction("U"), do: :U
  defp convert_direction("D"), do: :D

  defp manhattan_distance({x1, y1}, {x2, y2} \\ {0, 0}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  def read_data() do
    {:ok, file} = File.open(@input_file, [:read])

    [path1, path2] =
      IO.read(file, :all)
      |> String.split("\n")
      |> Enum.map(fn path_string -> String.split(path_string, ",") end)

    File.close(file)
    central = {0, 0}
    {traverse_path(path1, central, [central]), traverse_path(path2, central, [central])}
  end
end
