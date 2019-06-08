defmodule Bookie.User.Router do
  use Bookie, :router

  alias Bookie.User.{
    Controller
  }

  get("/", Controller, :index)
  post("/", Controller, :create)
  get("/:id", Controller, :get_user)
  put("/:id", Controller, :update)
  delete("/:id", Controller, :delete)
end
