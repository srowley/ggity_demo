defmodule GGityDemoWeb.HomeView do
  use GGityDemoWeb, :view

  alias GGity.{Examples, Labels, Plot}
  import GGity.Element.Text

  defp tx_housing_chart do
    GGity.Examples.tx_housing()
    |> Enum.filter(fn record ->
      record["city"] in ["Houston", "Fort Worth", "San Antonio", "Dallas", "Austin"]
    end)
    |> Plot.new(%{x: "sales", y: "median"})
    |> Plot.geom_point(%{color: "city"}, alpha: 0.4)
    |> Plot.scale_x_continuous(labels: :commas)
    |> Plot.scale_y_continuous(labels: fn value -> "$#{Labels.commas(round(value / 1000))}K" end)
    |> Plot.scale_color_viridis(option: :magma)
    |> Plot.labs(
      title: "Scatter Plot",
      x: "Sales",
      y: "Median Price",
      color: "City"
    )
    |> Plot.plot()
  end

  # defp economics_line do
  #   Examples.economics_long()
  #   |> Plot.new(%{x: "date", y: "value01"})
  #   |> Plot.labs(title: "Mapped to color")
  #   |> Plot.geom_line(%{color: "variable"})
  #   |> Plot.scale_x_date(breaks: 6, date_labels: "%Y")
  #   |> Plot.plot()
  # end

  # defp dodged_bar do
  #   Examples.mpg()
  #   |> Enum.filter(fn record ->
  #     record["manufacturer"] in ["chevrolet", "audi", "ford", "nissan", "subaru"]
  #   end)
  #   |> Plot.new(%{x: "manufacturer"})
  #   |> Plot.geom_bar(%{fill: "class"}, position: :dodge)
  #   |> Plot.plot()
  # end

  defp stacked_bar do
    Examples.mpg()
    |> Enum.filter(fn record ->
      record["manufacturer"] in ["chevrolet", "audi", "ford", "nissan", "subaru"]
    end)
    |> Plot.new(%{x: "manufacturer", label: :count, group: "class"})
    |> Plot.geom_bar(%{fill: "class"}, position: :stack)
    |> Plot.geom_text(
      color: "grey",
      stat: :count,
      position: :stack,
      position_vjust: 0.5,
      fontface: "bold",
      size: 6
    )
    |> Plot.scale_fill_viridis(option: :inferno)
    |> Plot.scale_y_continuous(breaks: 4, labels: fn value -> round(value) end)
    |> Plot.labs(
      title: "Bar Chart with Labels",
      x: "Manufacturer",
      y: "# of Models",
      fill: "Vehicle Class"
    )
    |> Plot.plot()
  end

  defp line_and_points do
    Examples.mtcars()
    |> Plot.new(%{x: :wt, y: :mpg})
    |> Plot.geom_line(linetype: :twodash, size: 1)
    |> Plot.geom_point(%{color: :cyl})
    |> Plot.labs(
      title: "Multiple Layers",
      x: "Weight (000s of lbs)",
      y: "Miles Per Gallon",
      color: "Cylinders"
    )
    |> Plot.plot()
  end

  defp area do
    Examples.economics_long()
    |> Enum.filter(fn row -> row["variable"] in ["psavert", "uempmed"] end)
    |> Plot.new(%{x: "date", y_max: "value01"})
    |> Plot.geom_area(%{fill: "variable"})
    |> Plot.scale_fill_viridis(option: :cividis)
    |> Plot.scale_y_continuous(labels: fn value -> Float.round(value, 2) end)
    |> Plot.scale_x_date(breaks: 20, date_labels: "%Y")
    |> Plot.labs(
      title: "Stacked Area Chart",
      x: "Date",
      y: "Illustrative Value",
      fill: "Metric"
    )
    |> Plot.theme(axis_text_x: element_text(angle: 30))
    |> Plot.plot()
  end
end
