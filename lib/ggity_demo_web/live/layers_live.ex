defmodule GGityDemoWeb.LayersLive do
  use GGityDemoWeb, :live_view

  alias GGity.Plot
  import GGity.Element.{Line, Rect, Text}

  @econ_data GGity.Examples.economics_long()

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

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(
       socket,
       mapping: %{x: "date", y: "value01", color: "variable"},
       metrics: ["uempmed", "unemploy"],
       fixed_aesthetics: %{line_size: 1, point_size: 4, label_font_size: 7},
       theme: @default_theme
     )}
  end

  @impl true
  def handle_event("update_mapping", %{"mapping" => params}, socket) do
    metrics =
      for {key, value} <- params, value == "true", do: String.trim_leading(key, "metrics_")

    aesthetic = String.to_atom(params["aesthetic"])
    mapping = Map.new([{:x, "date"}, {:y, "value01"}, {aesthetic, "variable"}])

    {:noreply, assign(socket, metrics: ["uempmed" | metrics], mapping: mapping)}
  end

  @impl true
  def handle_event("update_fixed", %{"fixed_aesthetics" => params}, socket) do
    fixed_aesthetics = for {key, value} <- params, do: {String.to_atom(key), cast(value)}, into: %{}
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

  defp draw_chart(mapping, metrics, fixed_aesthetics, theme) do
    base_data =
      Enum.filter(@econ_data, fn record ->
        record["variable"] in metrics &&
          Date.compare(record["date"], ~D[1968-12-31]) == :lt
      end)

    uempmed_only = Enum.filter(base_data, fn record -> record["variable"] == "uempmed" end)

    {%{"value01" => min_value01}, %{"value01" => max_value01}} =
      uempmed_only
      |> Enum.min_max_by(fn record -> record["value01"] end)

    min_record =
      Enum.filter(uempmed_only, fn record -> record["value01"] == min_value01 end)
      |> Enum.map(fn record ->
        Map.put(record, "value01_label", "Minimum: #{Float.round(record["value01"], 3)}")
      end)

    max_record =
      Enum.filter(uempmed_only, fn record -> record["value01"] == max_value01 end)
      |> Enum.map(fn record ->
        Map.put(record, "value01_label", "Maximum: #{Float.round(record["value01"], 3)}")
      end)

    base_data
    |> Plot.new()
    |> Plot.geom_line(mapping, size: fixed_aesthetics.line_size)
    |> Plot.geom_point(Map.take(mapping, [:x, :y]), data: min_record, size: fixed_aesthetics.point_size)
    |> Plot.geom_text(%{x: "date", y: "value01", label: "value01_label"},
      data: min_record,
      nudge_y: 10,
      size: fixed_aesthetics.label_font_size
    )
    |> Plot.geom_point(Map.take(mapping, [:x, :y]), data: max_record, size: fixed_aesthetics.point_size)
    |> Plot.geom_text(%{x: "date", y: "value01", label: "value01_label"},
      data: max_record,
      nudge_y: -10,
      size: fixed_aesthetics.label_font_size
    )
    |> Plot.scale_color_viridis(option: :plasma)
    |> Plot.labs(
      title: "Economic Time Series Data",
      x: "Date",
      y: "Normalized Value",
      color: "Metric",
      linetype: "Metric"
    )
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

  defp generated_code(mapping, metrics, fixed_aesthetics, theme) do
    ~s"""
    alias GGity.{Examples, Plot}
    import GGity.Element.{Line, Rect, Text}


    base_data =
      Enum.filter(Examples.economics_long(), fn record ->
        record["variable"] in #{inspect(metrics)} &&
          Date.compare(record["date"], ~D[1968-12-31]) == :lt
      end)


    uempmed_only = Enum.filter(base_data, fn record ->
      record["variable"] == "uempmed"
    end)


    min_record =
      Enum.filter(uempmed_only, fn record ->
        record["value01"] == min_value01
      end)
      |> Enum.map(fn record ->
        Map.put(
          record,
          "value01_label",
          "Minimum: \#{Float.round(record["value01"], 3)}"
        )
      end)


    max_record =
      Enum.filter(uempmed_only, fn record ->
        record["value01"] == max_value01
      end)
      |> Enum.map(fn record ->
        Map.put(
          record,
          "value01_label",
          "Maximum: \#{Float.round(record["value01"], 3)}"
        )
      end


    base_data
    |> Plot.new()
    |> Plot.geom_line(#{inspect(mapping)}#{code_for_line_size(fixed_aesthetics)})
    |> Plot.geom_point(
      %{x: "date", y: "value01"},
      data: min_record#{code_for_point_size(fixed_aesthetics)}
      )
    |> Plot.geom_text(
      %{x: "date", y: "value01", label: "value01_label"},
      data: min_record,
      nudge_y: 10,
      size: #{fixed_aesthetics.label_font_size}
      )
    |> Plot.geom_point(
      %{x: "date", y: "value01"},
      data: max_record#{code_for_point_size(fixed_aesthetics)}
      )
    |> Plot.geom_text(
      %{x: "date", y: "value01", label: "value01_label"},
      data: max_record,
      nudge_y: 10,
      size: #{fixed_aesthetics.label_font_size}
      )
    #{code_for_color_scale(mapping)}
    #{code_for_labels(mapping)}
    #{code_for_theme(theme)}
    |> Plot.plot()
    """
    |> String.replace("\n\n", "\n")
    |> Makeup.highlight()
  end

  defp code_for_line_size(%{line_size: 1}), do: ""
  defp code_for_line_size(fixed_aesthetics) do
    ", size: #{fixed_aesthetics.line_size}"
  end

  defp code_for_point_size(%{point_size: 4}), do: ""
  defp code_for_point_size(fixed_aesthetics) do
    ", size: #{fixed_aesthetics.point_size}"
  end

  defp code_for_color_scale(%{color: _variable}) do
    "|> Plot.scale_color_viridis(option: :plasma)"
  end
  defp code_for_color_scale(_mapping), do: ""

  defp code_for_labels(mapping) do
    """
    |> Plot.labs(
      title: "Economic Time Series Data",
      x: "Date",
      y: "Normalized Value",
      #{if mapping[:color], do: "color", else: "linetype"}: "Metric"
      )
    """
    |> String.trim()
  end

  defp strip_list_brackets("[" <> printed_list) do
    String.trim(printed_list, "]")
  end

  defp strip_list_brackets(not_a_list), do: not_a_list

  def pretty_label(variable), do: variable

  # defp pretty_label_list(mapping) do
  #   Enum.map(mapping, fn {aesthetic, variable} ->
  #     {aesthetic, pretty_label(variable)}
  #   end)
  # end

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
