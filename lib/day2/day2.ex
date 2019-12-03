defmodule Day2 do
  @input_file "./lib/day2/input"
  @part2_goal 19_690_720

  def part1() do
    {length, int_code_map} = read_data()

    scan_code(0, set_code_map({1, 2}, int_code_map), length)
    |> Map.get(0)
  end

  def part2() do
    {length, int_code_map} = read_data()
    {noun, verb} = do_part2(length, int_code_map, %{})
    100 * noun + verb
  end

  defp do_part2(length, int_code_map, guessed) do
    pair = gen_pair(guessed)

    scan_code(0, set_code_map(pair, int_code_map), length)
    |> Map.get(0)
    |> case do
      @part2_goal -> pair
      _ -> do_part2(length, int_code_map, Map.put(guessed, pair, nil))
    end
  end

  defp gen_pair(guessed) do
    pair = {:rand.uniform(100) - 1, :rand.uniform(100) - 1}

    case guessed do
      %{^pair => _} -> gen_pair(guessed)
      _ -> pair
    end
  end

  defp set_code_map({v1, v2}, code_map) do
    Map.put(code_map, 1, v1)
    |> Map.put(2, v2)
  end

  defp read_data() do
    {:ok, file} = File.open(@input_file, [:read])

    int_code_list =
      IO.read(file, :all)
      |> String.split(",")

    File.close(file)

    Enum.reduce(int_code_list, {0, %{}}, fn int_code, {index, acc} ->
      {index + 1, Map.put(acc, index, String.to_integer(int_code))}
    end)
  end

  defp scan_code(index, map, max) when index >= max - 1, do: map

  defp scan_code(index, map, max) do
    fun = op_code_to_fun(Map.get(map, index))

    case exec_op_code(fun, index, map) do
      {:con, new_map} -> scan_code(index + 4, new_map, max)
      {:fin, new_map} -> new_map
    end
  end

  defp exec_op_code(:fin, _index, map), do: {:fin, map}
  defp exec_op_code(nil, _index, map), do: {:con, map}

  defp exec_op_code(fun, index, map) do
    value = fun.(Map.get(map, Map.get(map, index + 1)), Map.get(map, Map.get(map, index + 2)))
    position = Map.get(map, index + 3)
    {:con, Map.put(map, position, value)}
  end

  defp op_code_to_fun(1), do: &Kernel.+/2
  defp op_code_to_fun(2), do: &Kernel.*/2
  defp op_code_to_fun(99), do: :fin
  defp op_code_to_fun(_), do: nil
end
