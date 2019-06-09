defmodule Bookie.UserMethod do
  use Bookie, :model

  use Ecto.Schema

  schema "users_methods" do
    belongs_to(:users, Bookie.User, type: :binary_id, foreign_key: :user_id)
    belongs_to(:methods, Bookie.Method, type: :binary_id, foreign_key: :method_id)
  end

  def map_user_method(user, methods) do
    user_methods = user.methods

    user
    |> Repo.preload(:methods)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:methods, user_methods ++ [methods])
    |> Repo.update()
  end

  def delete_user_method(user, methods) do
    user_methods = user.methods

    user
    |> Repo.preload(:methods)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:methods, user_methods -- [methods])
    |> Repo.update()
  end
end
