defmodule Day9 do
  @input_file "./lib/day9/input"

  def part1(input \\ [1]) do
    {length, int_code_map} = read_data(@input_file)
    Process.put(:inputs, input)

    {_, output} = scan_code(0, Map.put(int_code_map, :relative_base, 0), length - 1, nil)
    output
  end

  def part2(input \\ [2]) do
    {length, int_code_map} = read_data(@input_file)
    Process.put(:inputs, input)

    {_, output} = scan_code(0, Map.put(int_code_map, :relative_base, 0), length - 1, nil)
    output
  end

  defp read_data(file) do
    {:ok, file} = File.open(file, [:read])

    int_code_list =
      IO.read(file, :all)
      |> String.split(",")

    File.close(file)

    Enum.reduce(int_code_list, {0, %{}}, fn int_code, {index, acc} ->
      {index + 1, Map.put(acc, index, String.to_integer(int_code))}
    end)
  end

  defp scan_code(index, map, max, output) when index >= max, do: {map, output}

  defp scan_code(index, map, max, output) do
    case exec_op_code(Map.get(map, index), index, map, {0, 0, 0}) do
      {:con, new_map, next} -> scan_code(next, new_map, max, output)
      {:con, new_map, next, new_output} -> scan_code(next, new_map, max, new_output)
      {:fin, new_map} -> {new_map, output}
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

  defp exec_op_code(3, index, map, {m1, _, _}) do
    position = get_position(index + 1, map, m1)

    input =
      case Process.get(:inputs) do
        [] ->
          receive do
            {:input, value} ->
              value
          end

        [input | tail] ->
          Process.put(:inputs, tail)
          input
      end

    {:con, Map.put(map, position, input), index + 2}
  end

  defp exec_op_code(4, index, map, {m1, _, _}) do
    output = get_value(index + 1, map, m1)
    next = Process.get(:next)
    IO.inspect("output: #{output}")

    if next do
      Process.whereis(next) && send(next, {:input, output})
    end

    {:con, map, index + 2, output}
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

  defp exec_op_code(9, index, map, {m1, _m2, _m3}) do
    v1 = get_value(index + 1, map, m1)
    relative_base = Map.get(map, :relative_base) + v1
    {:con, Map.put(map, :relative_base, relative_base), index + 2}
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

    case mode do
      0 -> Map.get(map, p)
      1 -> p
      2 -> Map.get(map, Map.get(map, :relative_base) + p)
    end
  end

  defp get_position(index, map, mode) do
    p = Map.get(map, index)

    case mode do
      0 -> p
      2 -> Map.get(map, :relative_base) + p
    end
  end
end
