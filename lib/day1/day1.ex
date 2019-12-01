defmodule Day1 do
  @input_file "./lib/day1/input"

  def part1() do
    {:ok, file} = File.open(@input_file, [:read])
    read_line_reduce(IO.read(file, :line), file, 0, &sum_part1/2)
  end

  def part2() do
    {:ok, file} = File.open(@input_file, [:read])
    read_line_reduce(IO.read(file, :line), file, 0, &sum_part2/2)
  end

  defp read_line_reduce(:eof, file, acc, _reducer) do
    File.close(file)
    acc
  end

  defp read_line_reduce(raw, file, acc, reducer) do
    read_line_reduce(IO.read(file, :line), file, reducer.(convert(raw), acc), reducer)
  end

  defp sum_part1(mass, acc) do
    cal(mass) + acc
  end

  defp sum_part2(mass, acc) do
    do_sum_part2(cal(mass), acc)
  end

  defp do_sum_part2(mass, acc) when mass < 0, do: acc

  defp do_sum_part2(mass, acc) do
    sum_part2(mass, mass + acc)
  end

  defp convert(raw) do
    String.trim_trailing(raw)
    |> String.to_integer()
  end

  defp cal(mass) do
    floor(mass / 3 - 2)
  end
end
