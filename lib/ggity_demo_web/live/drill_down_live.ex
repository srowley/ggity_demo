defmodule GGityDemoWeb.DrillDownLive do
  use GGityDemoWeb, :live_view

  alias GGity.Plot

  @mpg_data GGity.Examples.mpg()

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       base_chart: draw_base_chart(),
       drill_down: "Click on a bar above to drill down by manufacturer."
     )}
  end

  @impl true
  def handle_event("bar_click", %{"manufacturer" => manufacturer}, socket) do
    {:noreply, assign(socket, drill_down: drill_down_chart(manufacturer))}
  end

  defp bar_custom_attributes do
    fn _plot, row ->
      [
        phx_click: "bar_click",
        phx_value_manufacturer: row["manufacturer"],
        class: "cursor-pointer"
      ]
    end
  end

  defp code(text) do
    raw(
      ~s|<code class="px-1 text-sm" style="background-color:#2f1e2e; color:#fec418">#{text}</code>|
    )
  end

  defp draw_base_chart() do
    @mpg_data
    |> Enum.filter(fn record ->
      record["manufacturer"] in [
        "chevrolet",
        "audi",
        "ford",
        "nissan",
        "subaru",
        "toyota",
        "hyundai"
      ]
    end)
    |> Plot.new(%{x: "manufacturer"})
    |> Plot.geom_bar(%{fill: "class"}, custom_attributes: bar_custom_attributes())
    |> Plot.scale_y_continuous(labels: &floor/1)
    |> Plot.labs(
      title: "Product Line Analysis",
      x: "Manufacturer",
      y: "Number of Models",
      fill: "Vehicle Classes"
    )
    |> Plot.plot()
  end

  defp drill_down_chart(manufacturer) do
    @mpg_data
    |> Enum.filter(fn record -> record["manufacturer"] == manufacturer end)
    |> Plot.new(%{x: "class"})
    |> Plot.geom_bar(%{fill: "trans"}, position: :dodge)
    |> Plot.scale_y_continuous(labels: &floor/1)
    |> Plot.scale_fill_viridis(option: :cividis)
    |> Plot.labs(
      title: "#{String.capitalize(manufacturer)} Transmission Type by Class",
      x: "Classes",
      y: "Number of Models",
      fill: "Transmission Types"
    )
    |> Plot.plot()
  end
end
