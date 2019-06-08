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
    Repo.get!(User, id)
  end

  @doc """
  This method will return user based on it's id
  This method will raise error in case data not found
  """
  def get_user!(id) do
    Repo.get!(User, id)
  end

  @doc """
  This method will get user by it's params
  whatever fields you want to query just send
  those field in keyword list in params
  """
  def get_user_by(params) do
    Repo.get_by(User, params)
  end

  def update(changeset, repo) do
    IO.inspect(changeset)

    changeset
    |> put_password_hashing()
    |> repo.update()
  end

  def put_password_hashing(changeset) do
    case changeset.changes |> Map.has_key?(:password) do
      true ->
        changeset
        |> Ecto.Changeset.put_change(
          :hashed_password,
          hashed_password(changeset.changes[:password])
        )

      false ->
        changeset
    end
  end

  def delete_user(_id) do
    # delete user
  end

  defp authenticate(user, password) do
    case user do
      nil -> false
      _ -> Bcrypt.verify_pass(password, user.hashed_password)
    end
  end

  def check_user_credentials(params, repo) do
    user = repo.get_by(User, name: params["name"])

    case authenticate(user, params["password"]) do
      true -> {:ok, user}
      _ -> {:error, "wrong credentials"}
    end
  end

  defp hashed_password(password), do: Bcrypt.hash_pwd_salt(password)
end
