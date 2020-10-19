# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :ggity_demo,
  namespace: GGityDemo

# Configures the endpoint
config :ggity_demo, GGityDemoWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "qC1p0aS8elvLagaVgPUc+O6XQn1QMcQIKXC4aOYIT5W2oIATy/1I9p0zXxzbMCMJ",
  render_errors: [view: GGityDemoWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: GGityDemo.PubSub,
  live_view: [signing_salt: "yjONfSsW"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
