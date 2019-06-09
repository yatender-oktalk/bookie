defmodule BookieWeb.Router do
  use BookieWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", BookieWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)
  end

  # Other scopes may use custom stacks.
  scope "/api", Bookie do
    pipe_through(:api)

    forward("/health", Health.Router)
    forward("/users", User.Router)
    forward("/methods", Method.Router)
    forward("/books", Book.Router)
    forward("/authors", Author.Router)
  end
end
