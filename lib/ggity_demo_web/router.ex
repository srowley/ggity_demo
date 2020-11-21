defmodule GGityDemoWeb.Router do
  use GGityDemoWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {GGityDemoWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", GGityDemoWeb do
    pipe_through :browser

    get "/", HomeController, :index
    live "/scatter", ScatterLive
    live "/bar", BarLive
    live "/layers", LayersLive
  end
end
