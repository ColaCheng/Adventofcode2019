defmodule Day5 do
  @input_file "./lib/day5/input"
  @part1_input 1
  @part2_input 5

  def part1() do
    {length, int_code_map} = read_data()
    Process.put(:input, @part1_input)

    scan_code(0, int_code_map, length - 1)
    |> Map.get(0)
  end

  def part2() do
    {length, int_code_map} = read_data()
    Process.put(:input, @part2_input)

    scan_code(0, int_code_map, length - 1)
    |> Map.get(0)
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

  defp scan_code(index, map, max) when index >= max, do: map

  defp scan_code(index, map, max) do
    case exec_op_code(Map.get(map, index), index, map, {0, 0, 0}) do
      {:con, new_map, next} -> scan_code(next, new_map, max)
      {:fin, new_map} -> new_map
    end
  end

  defp exec_op_code(1, index, map, {m1, m2, m3}) do
    v1 = get_value(index + 1, map, m1)
    v2 = get_value(index + 2, map, m2)
    position = get_position(index + 3, map, m3)
    value = v1 + v2
    {:con, Map.put(map, position, value), index + 4}
  end

  defp exec_op_code(2, index, map, {m1, m2, m3}) do
    v1 = get_value(index + 1, map, m1)
    v2 = get_value(index + 2, map, m2)
    position = get_position(index + 3, map, m3)
    value = v1 * v2
    {:con, Map.put(map, position, value), index + 4}
  end

  defp exec_op_code(3, index, map, _) do
    position = Map.get(map, index + 1)
    {:con, Map.put(map, position, Process.get(:input)), index + 2}
  end

  defp exec_op_code(4, index, map, _) do
    position = Map.get(map, index + 1)
    IO.inspect("Output: #{Map.get(map, position)}")
    {:con, map, index + 2}
  end

  defp exec_op_code(5, index, map, {m1, m2, _m3}) do
    v1 = get_value(index + 1, map, m1)
    v2 = get_value(index + 2, map, m2)
    (v1 != 0 && {:con, map, v2}) || {:con, map, index + 3}
  end

  defp exec_op_code(6, index, map, {m1, m2, _m3}) do
    v1 = get_value(index + 1, map, m1)
    v2 = get_value(index + 2, map, m2)
    (v1 == 0 && {:con, map, v2}) || {:con, map, index + 3}
  end

  defp exec_op_code(7, index, map, {m1, m2, m3}) do
    v1 = get_value(index + 1, map, m1)
    v2 = get_value(index + 2, map, m2)
    position = get_position(index + 3, map, m3)
    value = (v1 < v2 && 1) || 0
    {:con, Map.put(map, position, value), index + 4}
  end

  defp exec_op_code(8, index, map, {m1, m2, m3}) do
    v1 = get_value(index + 1, map, m1)
    v2 = get_value(index + 2, map, m2)
    position = get_position(index + 3, map, m3)
    value = (v1 == v2 && 1) || 0
    {:con, Map.put(map, position, value), index + 4}
  end

  defp exec_op_code(99, _index, map, _) do
    {:fin, map}
  end

  defp exec_op_code(instruction, index, map, _) do
    opcode = rem(instruction, 100)
    mode1 = rem(instruction, 1000) |> div(100)
    mode2 = rem(instruction, 10000) |> div(1000)
    mode3 = rem(instruction, 100_000) |> div(10000)
    exec_op_code(opcode, index, map, {mode1, mode2, mode3})
  end

  defp get_value(index, map, mode) do
    p = Map.get(map, index)
    (mode == 0 && Map.get(map, p)) || p
  end

  defp get_position(index, map, mode) do
    p = Map.get(map, index)
    (mode == 0 && p) || Map.get(map, p)
  end
end
