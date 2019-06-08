defmodule Bookie.Book.Router do
  use Bookie, :router

  alias Bookie.Book.{
    Controller
  }

  get("/", Controller, :index)
  post("/", Controller, :create)
  get("/:id", Controller, :index)
  put("/:id", Controller, :update)
  delete("/:id", Controller, :delete)
end
