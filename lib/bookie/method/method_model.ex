defmodule Bookie.Method.Model do
  use Bookie, :model

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "methods" do
    field(:function, :string, required: true)
    field(:method, :string, required: true)
    timestamps()

    many_to_many(:users, Bookie.User.Model, join_through: "users_methods", on_replace: :delete)
  end

  @doc """
  This method will return Method based on it's id
  """
  def get_method(id) do
    Repo.get!(Bookie.Method.Model, id)
  end

  @doc """
  This method will return Method based on it's id
  This method will raise error in case data not found
  """
  def get_method!(id) do
    Repo.get!(Bookie.Method.Model, id)
  end

  @doc """
  This method will get Method by it's params
  whatever fields you want to query just send
  those field in keyword list in params
  """
  def get_method_by(params) do
    Repo.get_by(Bookie.Method.Model, params)
  end

  def create_method(_params) do
    # validate with changeset
  end

  def update_method(_id, _params) do
    # check chengeset
  end

  def delete_method(_id) do
    # delete Method
  end
end
