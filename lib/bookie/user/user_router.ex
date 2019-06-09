defmodule Bookie.User.Router do
  @moduledoc """
  User.Router module to write user related all api/resources here
  path of this route will be
  {hostname}/api/users

   * API to get all users
   GET {hostname}/api/users

   * API to get a single user
   GET {hostname}/api/users/{user_id}

   * API to create a user
   POST {hostname}/api/users

   * API to update a user
   PUT {hostname}/api/users/{user_id}

   * API to delete a user
   DELETE {hostname}/api/users/{user_id}

   * API to get a user's all available methods
   GET {hostname}/api/users/{user_id}/methods

   * API to add method with user
   PUT {hostname}/api/users/{user_id}/methods/{method_id}

   * API to remove method from user
   DELETE {hostname}/api/users/{user_id}/methods/{method_id}

   NOTE: Full description is available at

   https://github.com/yatender-oktalk/bookie/wiki/API-description
  """
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
