defmodule BookieWeb.Router do
  @moduledoc """
  This module is the main entry point for all requests
  If you want to create new resources just add under web or api scope
  and declare their modules at respective places.
  """

  use BookieWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  # A general pipeline built only for api calls here we will do all authrization and authentication check
  # This pipeline will make sure that request doesn't go inside modules
  pipeline :api do
    plug(:accepts, ["json"])
    plug(Plugs.DBHealthPlug)
    plug(Plugs.NoAuthPathPlug)
    plug(Plugs.AuthPlug)
  end

  scope "/", BookieWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)
  end

  # Other scopes may use custom stacks.
  # This scope is specifically built for api calls only
  scope "/api", Bookie do
    pipe_through(:api)

    forward("/health", Health.Router)
    forward("/users", User.Router)
    forward("/methods", Method.Router)
    forward("/books", Book.Router)
    forward("/authors", Author.Router)
  end
end
