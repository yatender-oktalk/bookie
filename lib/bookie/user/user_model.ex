defmodule Bookie.User.Model do
  use Bookie, :model

  alias Bookie.User.Model, as: User
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "users" do
    field(:name, :string, required: true)
    field(:hashed_password, :string, required: true)
    field(:password, :string, virtual: true)
    timestamps()

    many_to_many(:methods, Bookie.Method.Model, join_through: "users_methods", on_replace: :delete)
  end

  @required_fields ~w(name password)
  @optional_fields ~w()

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:name)
    |> validate_length(:name, min: 2)
    |> validate_length(:password, min: 5)
  end

  def create_user(changeset, repo) do
    changeset
    |> Ecto.Changeset.put_change(:hashed_password, hashed_password(changeset.changes[:password]))
    |> repo.insert()
  end

  @doc """
  This method will return user based on it's id
  """
  def get_user(id) do
    Repo.get!(Bookie.User.Model, id)
  end

  @doc """
  This method will return user based on it's id
  This method will raise error in case data not found
  """
  def get_user!(id) do
    Repo.get!(Bookie.User.Model, id)
  end

  @doc """
  This method will get user by it's params
  whatever fields you want to query just send
  those field in keyword list in params
  """
  def get_user_by(params) do
    Repo.get_by(Bookie.User.Model, params)
  end

  def update_user(_id, _params) do
    # check chengeset
  end

  def delete_user(_id) do
    # delete user
  end

  defp hashed_password(password), do: Bcrypt.hash_pwd_salt(password)
end
