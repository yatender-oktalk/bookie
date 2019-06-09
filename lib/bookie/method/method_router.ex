defmodule Bookie.Method.Router do
  use Bookie, :router

  alias Bookie.Method.{
    Controller
  }

  get("/", Controller, :index)
  post("/", Controller, :create)
  get("/:id", Controller, :get_method)
  put("/:id", Controller, :update)
  delete("/:id", Controller, :delete)
  get("/:id/users", Controller, :method_users)
end
