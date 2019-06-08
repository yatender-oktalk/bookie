defmodule Bookie.UserMethod.Model do
  use Bookie, :model

  use Ecto.Schema

  schema "users_methods" do
    belongs_to(:users, Bookie.User.Model, type: :binary_id)
    belongs_to(:methods, Bookie.Method.Model, type: :binary_id)
  end
end
