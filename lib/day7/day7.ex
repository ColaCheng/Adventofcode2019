defmodule Day7 do
  @input_file "./lib/day7/input"
  @input 0

  def part1(file \\ @input_file) do
    {length, int_code_map} = read_data(file)

    Enum.map(
      permutations(Enum.map(0..4, & &1)),
      &run_amplifiers(&1, int_code_map, length, @input)
    )
    |> Enum.max()
  end

  def part2(file \\ @input_file) do
    {length, int_code_map} = read_data(file)

    Enum.map(permutations(Enum.map(5..9, & &1)), &feedback_loop(&1, int_code_map, length))
    |> Enum.max()
  end

  defp feedback_loop([h | t] = phases, int_code_map, length) do
    phase_names = Enum.map(t ++ [h], &String.to_atom("phase#{&1}"))

    pid =
      Enum.zip(phases, phase_names)
      |> Enum.reduce(nil, fn phase, _ ->
        run_amplifier(phase, int_code_map, String.to_atom("phase#{h}"), self(), length)
      end)

    send(String.to_atom("phase#{h}"), {:input, @input})

    receive do
      {^pid, output} ->
        output
    end
  end

  defp run_amplifier({phase, next}, int_code_map, begin, return_pid, length) do
    pid =
      spawn(fn ->
        input =
          receive do
            {:input, input} ->
              input
          end

        Process.put(:inputs, [phase, input])
        Process.put(:next, next)
        {_, output} = scan_code(0, int_code_map, length - 1, nil)
        begin == next && send(return_pid, {self(), output})
      end)

    Process.register(pid, String.to_atom("phase#{phase}"))
    pid
  end

  defp run_amplifiers([], _int_code_map, _length, output), do: output

  defp run_amplifiers([phase | tail], int_code_map, length, output) do
    Process.put(:inputs, [phase, output])

    {_, output} = scan_code(0, int_code_map, length - 1, nil)
    run_amplifiers(tail, int_code_map, length, output)
  end

  def permutations(source) do
    for element <- source,
        remaining <- permutations(source -- [element]),
        do: [element | remaining]
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

  defp exec_op_code(3, index, map, _) do
    position = Map.get(map, index + 1)

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

  defp exec_op_code(4, index, map, _) do
    position = Map.get(map, index + 1)
    output = Map.get(map, position)
    next = Process.get(:next)

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
