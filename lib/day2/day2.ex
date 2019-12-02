defmodule Day2 do
  @input_file "./lib/day2/input"

  def part1() do
    {:ok, file} = File.open(@input_file, [:read])

    int_code_list =
      IO.read(file, :all)
      |> String.split(",")

    File.close(file)

    {length, int_code_map} =
      Enum.reduce(int_code_list, {0, %{}}, fn int_code, {index, acc} ->
        {index + 1, Map.put(acc, index, String.to_integer(int_code))}
      end)

    int_code_map =
      Map.put(int_code_map, 1, 12)
      |> Map.put(2, 2)

    scan_code(0, int_code_map, length)
    |> Map.get(0)
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
