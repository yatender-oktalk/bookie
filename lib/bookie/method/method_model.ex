defmodule Bookie.Method.Model do
  use Bookie, :model
  alias Bookie.Method.Model, as: Method
  alias Bookie.User.Model, as: User
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "methods" do
    field(:function, :string, required: true)
    field(:method, :string, required: true)
    timestamps()

    many_to_many(:users, Bookie.User.Model, join_through: "users_methods", on_replace: :delete)
  end

  @required_fields ~w(method function)
  @optional_fields ~w()
  @doc """
  This method will return Method based on it's id
  """
  def get_method(id) do
    Repo.get!(Method, id)
  end

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_required(:function)
    |> validate_required(:method)
    |> unique_constraint(:function_method_unique_contraint, name: :function_method_uniqe)
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

  def create_method(changeset, repo) do
    repo.insert(changeset)
    # validate with changeset
  end

  def update_method(changeset, repo) do
    repo.insert(changeset, repo)
  end

  def delete_method(_id) do
    # delete Method
  end

  def upsert_user_methods(user, method_ids) when is_list(method_ids) do
    methods =
      Method
      |> where([method], method.id in ^method_ids)
      |> Repo.all()

    with {:ok, _struct} <-
           user
           |> User.changeset_update_methods(methods)
           |> Repo.update() do
      {:ok, User.get_user(user.id)}
    else
      error ->
        error
    end
  end
end
