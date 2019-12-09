defmodule Day8 do
  @input_file "./lib/day8/input"
  @part1_wide 25
  @part1_tall 6

  def part1(file \\ @input_file) do
    {digits, _} =
      read_data(file)
      |> parse_layers(@part1_wide, @part1_tall)
      |> Enum.reduce({nil, @part1_wide * @part1_tall}, fn
        {_index, {digits, zero_count}}, {_, pre_zero_count} when zero_count < pre_zero_count ->
          {digits, zero_count}

        _, acc ->
          acc
      end)

    count_num_digit(digits, "1", 0) * count_num_digit(digits, "2", 0)
  end

  def part2(file \\ @input_file) do
    layers =
      read_data(file)
      |> parse_layers(@part1_wide, @part1_tall)

    num_layers = map_size(layers) - 1

    Enum.reduce(0..(@part1_wide * @part1_tall - 1), "", fn
      pos, acc ->
        acc <> confirm_pos_digit(layers, pos, num_layers)
    end)
    |> make_image(@part1_wide)
    |> IO.puts()
  end

  defp make_image(digits, wide) do
    String.replace(digits, "0", " ")
    |> String.replace("1", "*")
    |> do_make_image(wide, [])
    |> Enum.reverse()
    |> IO.iodata_to_binary()
  end

  defp do_make_image(<<>>, _wide, acc), do: acc

  defp do_make_image(digits, wide, acc) do
    <<part::binary-size(wide), res::binary>> = digits
    do_make_image(res, wide, [part, "\n" | acc])
  end

  defp confirm_pos_digit(layers, pos, num_layers) do
    do_confirm_pos_digit(layers, 1, pos, num_layers, get_layer_pos_digit(layers, 0, pos))
  end

  defp do_confirm_pos_digit(_layers, _index, _pos, _num_layers, "0"), do: "0"
  defp do_confirm_pos_digit(_layers, _index, _pos, _num_layers, "1"), do: "1"

  defp do_confirm_pos_digit(layers, num_layers, pos, num_layers, _layer_pos_digit),
    do: get_layer_pos_digit(layers, num_layers, pos)

  defp do_confirm_pos_digit(layers, index, pos, num_layers, "2") do
    do_confirm_pos_digit(
      layers,
      index + 1,
      pos,
      num_layers,
      get_layer_pos_digit(layers, index, pos)
    )
  end

  defp do_confirm_pos_digit(layers, index, pos, _num_layers, _layer_pos_digit),
    do: get_layer_pos_digit(layers, index, pos)

  defp get_layer_pos_digit(layers, index, pos) do
    Map.get(layers, index)
    |> elem(0)
    |> get_pos_digit(pos)
  end

  def read_data(file) do
    {:ok, file} = File.open(file, [:read])

    digits = IO.read(file, :all)

    File.close(file)

    digits
  end

  defp parse_layers(digits, wide, tall) do
    do_parse_layers(digits, wide * tall, 0, %{})
  end

  defp do_parse_layers(<<>>, _setting, _num, acc), do: acc

  defp do_parse_layers(digits, setting, num, acc) do
    <<layer::binary-size(setting), res::binary>> = digits

    do_parse_layers(
      res,
      setting,
      num + 1,
      Map.put(acc, num, {layer, count_num_digit(layer, "0", 0)})
    )
  end

  defp count_num_digit(<<>>, _digit, acc), do: acc

  defp count_num_digit(<<digit::binary-size(1), res::binary>>, digit, acc),
    do: count_num_digit(res, digit, acc + 1)

  defp count_num_digit(<<_::binary-size(1), res::binary>>, digit, acc),
    do: count_num_digit(res, digit, acc)

  defp get_pos_digit(<<digit::binary-size(1), _res::binary>>, 0), do: digit

  defp get_pos_digit(digits, pos) do
    <<_offset::binary-size(pos), digit::binary-size(1), _res::binary>> = digits
    digit
  end
end
