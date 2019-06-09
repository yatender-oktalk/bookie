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
  get("/:id/methods", Controller, :user_methods)
  put("/:id/methods/:method_id", Controller, :user_method_add)
  delete("/:id/methods/:method_id", Controller, :user_method_remove)
end
