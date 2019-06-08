defmodule Bookie.UserMethod.Model do
  use Bookie, :model

  use Ecto.Schema

  schema "users_methods" do
    belongs_to(:users, Bookie.User.Model, type: :binary_id)
    belongs_to(:methods, Bookie.Method.Model, type: :binary_id)
  end

  def map_user_method(user, methods) do
    user_methods = user.methods

    user
    |> Repo.preload(:methods)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:methods, user_methods ++ [methods])
    |> Repo.update()
  end
end
