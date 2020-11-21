defmodule GGityDemoWeb.HomeController do
  use GGityDemoWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
