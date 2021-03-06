defmodule GGityDemoWeb.ScatterLive do
  use GGityDemoWeb, :live_view

  alias GGity.Plot
  import GGity.Element.{Line, Rect, Text}

  @mtcars_data GGity.Examples.mtcars()
               |> Enum.map(fn record ->
                 Enum.map(record, fn {key, value} -> {to_string(key), value} end)
                 |> Enum.into(%{})
               end)

  @default_theme [
    text: [family: "Helvetica, Arial, sans-serif"],
    axis_text_x: [angle: 0],
    panel_background: [fill: "#EEEEEE"],
    legend_key: [fill: "#EEEEEE"],
    axis_line: [size: 0.5, color: nil],
    axis_ticks_length: 2,
    panel_grid: [color: "#FFFFFF"],
    panel_grid_major: [size: 1]
  ]

  # @mapping_params [:x, :y, :color, :color_scale_option, :shape]
  # @fixed_aesthetic_params [:color, :alpha, :size]

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(
       socket,
       mapping: %{x: "qsec", y: "mpg", color: "gear"},
       scales: [color_scale_option: :cividis],
       fixed_aesthetics: [alpha: 1],
       theme: @default_theme
     )}
  end

  @impl true
  def handle_event("update_mapping", %{"mapping" => params}, socket) do
    mapping =
      for {key, value} <- params,
          key != "color_scale_option",
          value != "none",
          do: {String.to_existing_atom(key), cast(value)},
          into: %{}

    color_scale_option = String.to_existing_atom(params["color_scale_option"]) || :viridis
    {:noreply, assign(socket, mapping: mapping, scales: [color_scale_option: color_scale_option])}
  end

  @impl true
  def handle_event("update_fixed", %{"fixed_aesthetics" => params}, socket) do
    fixed_aesthetics =
      for {key, value} <- params,
          do: {String.to_existing_atom(key), cast(value)}

    {:noreply, assign(socket, fixed_aesthetics: fixed_aesthetics)}
  end

  @impl true
  def handle_event("update_theme", %{"theme" => params}, socket) do
    params = for {key, value} <- params, do: {key, cast(value)}, into: %{}

    theme = [
      text: [family: params["base_font_family"]],
      axis_line: [size: 0.5, color: params["axis_line_color"]],
      axis_text_x: [angle: params["angle"]],
      axis_ticks_length: params["axis_ticks_length"],
      legend_key: [fill: params["legend_key_fill"]],
      panel_background: [fill: params["panel_background_fill"]],
      panel_grid: [color: params["panel_grid_color"]],
      panel_grid_major: [size: params["panel_grid_major_size"]]
    ]

    {:noreply, assign(socket, theme: theme)}
  end

  defp cast(""), do: nil

  defp cast(value) do
    try do
      String.to_integer(value)
    rescue
      ArgumentError ->
        case Float.parse(value) do
          {float, _binary} -> float
          :error -> value
        end
    end
  end

  defp discrete_variable_options do
    [:cyl, :am, :gear]
  end

  defp continuous_variable_options do
    [:wt, :mpg, :qsec, :disp]
  end

  defp font_options do
    [
      Default: "Helvetica, Arial, sans-serif",
      "Roboto Slab": "Roboto Slab",
      Oswald: "Oswald",
      serif: "serif",
      "sans-serif": "sans-serif",
      monospace: "monospace"
    ]
  end

  defp draw_chart(mapping, fixed_aesthetics, scales, theme) do
    @mtcars_data
    |> Plot.new()
    |> Plot.geom_point(mapping, fixed_aesthetics)
    |> Plot.scale_color_viridis(option: scales[:color_scale_option])
    |> Plot.scale_size_discrete()
    |> Plot.labs([{:title, "Motor Trend Statistics"} | pretty_label_list(mapping)])
    |> Plot.theme(
      text: element_text(family: theme[:text][:family]),
      axis_line: element_line(theme[:axis_line]),
      axis_text_x: element_text(theme[:axis_text_x]),
      axis_ticks_length: theme[:axis_ticks_length],
      panel_background: element_rect(theme[:panel_background]),
      legend_key: element_rect(theme[:legend_key]),
      panel_grid_major: element_line(theme[:panel_grid_major]),
      panel_grid: element_line(theme[:panel_grid])
    )
    |> Plot.plot()
  end

  defp generated_code(mapping, fixed_aesthetics, scales, theme) do
    ~s"""
    alias GGity.{Examples, Plot}
    import GGity.Element.{Line, Rect, Text}


    Examples.mtcars()
    |> Plot.new(#{code_for_x_y(mapping)})
    |> Plot.geom_point(#{code_for_geom(mapping, fixed_aesthetics)})
    #{code_for_color_scale(scales, mapping)}
    #{code_for_labels()}
    #{code_for_theme(theme)}
    |> Plot.plot()
    """
    |> String.replace("\n\n", "\n")
    |> Makeup.highlight()
  end

  defp code_for_x_y(mapping) do
    "%{x: :#{mapping.x}, y: :#{mapping.y}}"
  end

  defp code_for_geom(mapping, fixed_aesthetics) when map_size(mapping) == 1 do
    code_for_fixed_aes(fixed_aesthetics)
  end

  defp code_for_geom(mapping, alpha: 1) do
    code_for_mapped_aes(mapping)
  end

  defp code_for_geom(mapping, fixed_aesthetics) do
    actually_fixed_aesthetics =
      for {key, value} <- fixed_aesthetics,
          key not in Map.keys(mapping),
          {key, value} != {:alpha, 1},
          {key, value} != {:size, 4},
          do: {key, value}

    case actually_fixed_aesthetics do
      [] ->
        code_for_mapped_aes(mapping)

      actually_fixed_aesthetics ->
        Enum.join(
          [code_for_mapped_aes(mapping), code_for_fixed_aes(actually_fixed_aesthetics)],
          ", "
        )
    end
  end

  defp code_for_mapped_aes(mapping) do
    mapped =
      mapping
      |> Map.drop([:x, :y])
      |> inspect()
      |> String.replace(": \"", ": :")
      |> String.replace("\"}", "}")
      |> String.replace("\", ", ", ")

    case mapped do
      "%{}" -> ""
      mapped -> mapped
    end
  end

  defp code_for_fixed_aes([]), do: ""
  defp code_for_fixed_aes(alpha: 1), do: ""

  defp code_for_fixed_aes(fixed_aesthetics) do
    fixed_aesthetics
    |> List.delete({:alpha, 1})
    |> inspect()
    |> strip_list_brackets()
  end

  defp code_for_color_scale([color_scale_option: :viridis], _mapping), do: ""

  defp code_for_color_scale(scales, mapping) when is_map_key(mapping, :color) do
    "|> Plot.scale_color_viridis(option: :#{to_string(scales[:color_scale_option])})"
  end

  defp code_for_color_scale(_scales, _mapping), do: ""

  defp code_for_labels() do
    """
    |> Plot.labs(title: "Motor Trend Statistics")
    """
    |> String.trim()
  end

  defp strip_list_brackets("[" <> printed_list) do
    String.trim(printed_list, "]")
  end

  defp strip_list_brackets(not_a_list), do: not_a_list

  def pretty_label(variable), do: variable

  defp pretty_label_list(mapping) do
    Enum.map(mapping, fn {aesthetic, variable} ->
      {aesthetic, pretty_label(variable)}
    end)
  end

  # defp pretty_labels(mapping) do
  #   mapping
  #   |> Enum.reverse()
  #   |> Enum.map_join(",\n  ", fn {key, value} ->
  #     "#{Atom.to_string(key)}: \"#{pretty_label(value)}\""
  #   end)
  # end

  defp code_for_theme(theme) do
    custom_theme_elements =
      for element <- theme, code_for_element(element) != "", do: code_for_element(element)

    case custom_theme_elements do
      [] -> ""
      elements -> "|> Plot.theme(\n  " <> Enum.join(elements, ", \n  ") <> "\n)"
    end
  end

  defp code_for_element({key, options} = element) when is_list(options) do
    changed = for option <- options, option not in @default_theme[key], do: option

    if same_as_default?(element) or is_nil(changed) do
      ""
    else
      "#{key}: #{element_wrapper({key, changed})}"
    end
  end

  defp code_for_element({key, options} = element) do
    if same_as_default?(element) or is_nil(options) do
      ""
    else
      "#{key}: #{element_wrapper(element)}"
    end
  end

  defp element_wrapper({key, value}) do
    case key do
      :panel_background -> "element_rect(#{list_without_brackets(value)})"
      :legend_key -> "element_rect(#{list_without_brackets(value)})"
      :text -> "element_text(#{list_without_brackets(value)})"
      :axis_text_x -> "element_text(#{list_without_brackets(value)})"
      _key when is_list(value) -> "element_line(#{list_without_brackets(value)})"
      _key -> value
    end
  end

  defp list_without_brackets(list) do
    list
    |> inspect()
    |> strip_list_brackets()
  end

  defp same_as_default?({key, value}) do
    @default_theme[key] == value
  end
end
