# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :bookie,
  ecto_repos: [Bookie.Repo]

# Configures the endpoint
config :bookie, BookieWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "R/GtBJjMjAg2KlmNsaL26h8WZCtpiKiQxrAtz39Q7QMv3/z3CD4uQ9nnuovI8GTK",
  render_errors: [view: BookieWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Bookie.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :bookie, :env,
  non_auth_paths: [{"POST", "/api/users/"}],
  non_auth_req_type: ["GET"]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
