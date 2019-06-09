defmodule Bookie.User do
  use Bookie, :model

  alias Bookie.User, as: User
  alias Bookie.Method, as: Method
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "users" do
    field(:name, :string, required: true)
    field(:hashed_password, :string, required: true)
    field(:password, :string, virtual: true)
    timestamps()

    many_to_many(:methods, Bookie.Method,
      join_through: "users_methods",
      on_replace: :delete
    )
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

  def get_users(limit, offset) do
    query =
      from(u in User,
        limit: ^limit,
        offset: ^offset,
        select: %{id: u.id, inserted_at: u.inserted_at, name: u.name}
      )

    Repo.all(query)
  end

  @doc """
  This method will return user based on it's id
  """
  def get_user(id) do
    Repo.get(User, id)
  end

  def get_user_methods(id) do
    Repo.get(User, id) |> Repo.preload(:methods)
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

  def delete_user(user, repo) do
    repo.delete(user)
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

  def parse_user(nil) do
    {:erorr, "user not found"}
  end

  def parse_user(user) do
    methods = Method.parse_method(user.methods)

    parsed_user = %{
      id: user.id,
      name: user.name,
      insert_at: user.inserted_at,
      methods: methods
    }

    {:ok, parsed_user}
  end

  def parse_user_no_method(nil) do
    {:erorr, "user not found"}
  end

  def parse_user_no_method(user) do
    parsed_user = %{
      id: user.id,
      name: user.name,
      insert_at: user.inserted_at
    }

    {:ok, parsed_user}
  end

  def parse_user_for_method(users) when is_list(users) do
    users
    |> Enum.map(&parse_user_for_method/1)
    |> Enum.reject(fn user -> user == %{} end)
  end

  def parse_user_for_method(user) do
    case parse_user_no_method(user) do
      {:ok, user} -> user
      _ -> %{}
    end
  end

  def hashed_password(password), do: Bcrypt.hash_pwd_salt(password)
end
