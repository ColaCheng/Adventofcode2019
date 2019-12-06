defmodule Day6 do
  @input_file "./lib/day6/input"

  def part1() do
    {:ok, file} = File.open(@input_file, [:read])
    orbits_map = read_line_reduce(IO.read(file, :line), file, %{}, &build_orbits_map/2)

    Enum.reduce(orbits_map, 0, fn
      {_child, nil}, acc -> acc
      {_child, parent}, acc -> sum_indirect_orbits(orbits_map, parent, acc + 1)
    end)
  end

  def part2() do
    {:ok, file} = File.open(@input_file, [:read])
    orbits_map = read_line_reduce(IO.read(file, :line), file, %{}, &build_orbits_map/2)
    path1 = get_all_path(orbits_map, "YOU", [])
    path2 = get_all_path(orbits_map, "SAN", [])
    length(path1 -- path2) + length(path2 -- path1)
  end

  defp get_all_path(map, node, acc) do
    case Map.get(map, node, nil) do
      "COM" -> Enum.reverse(acc)
      parent -> get_all_path(map, parent, [parent | acc])
    end
  end

  defp read_line_reduce(:eof, file, acc, _reducer) do
    File.close(file)
    acc
  end

  defp read_line_reduce(raw, file, acc, reducer) do
    read_line_reduce(IO.read(file, :line), file, reducer.(parse(raw), acc), reducer)
  end

  defp build_orbits_map([node1, node2], map) do
    case Map.get(map, node1, nil) do
      nil -> Map.put(map, node1, nil)
      _ -> map
    end
    |> Map.put(node2, node1)
  end

  defp sum_indirect_orbits(map, node, acc) do
    case Map.get(map, node, nil) do
      nil -> acc
      parent -> sum_indirect_orbits(map, parent, acc + 1)
    end
  end

  defp parse(raw) do
    String.trim_trailing(raw)
    |> String.split(")")
  end
end
