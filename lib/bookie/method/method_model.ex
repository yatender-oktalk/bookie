defmodule Bookie.Method do
  use Bookie, :model
  alias Bookie.{Method, User}

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "methods" do
    field(:function, :string, required: true)
    field(:method, :string, required: true)
    timestamps()

    many_to_many(:users, Bookie.User, join_through: "users_methods", on_replace: :delete)
  end

  @required_fields ~w(method function)
  @optional_fields ~w()

  @doc """
  This method will return Method based on it's id
  """
  def get_method(id) do
    Repo.get!(Method, id)
  end

  def get_methods(limit, offset) do
    query =
      from(u in Method,
        limit: ^limit,
        offset: ^offset,
        select: %{id: u.id, inserted_at: u.inserted_at, function: u.function, method: u.method}
      )

    Repo.all(query)
  end

  def get_method_users(id) do
    Repo.get(Method, id) |> Repo.preload(:users)
  end

  def parse_method(methods) when methods in [nil, []] do
    []
  end

  def parse_method(methods) when is_list(methods) do
    methods
    |> Enum.map(fn method ->
      parse_method(method)
    end)
  end

  def parse_method(method) do
    %{
      function: method.function,
      id: method.id,
      method: method.method
    }
  end

  def parse_method_for_model(methods) when methods in [nil, []] do
    {:error, "method not found"}
  end

  def parse_method_for_model(methods) when is_list(methods) do
    resp = methods |> Enum.map(&parse_method/1)
    {:ok, resp}
  end

  def parse_method_for_model(method) do
    {:ok, parse_method(method)}
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
    Repo.get!(Bookie.Method, id)
  end

  @doc """
  This method will get Method by it's params
  whatever fields you want to query just send
  those field in keyword list in params
  """
  def get_method_by(params) do
    Repo.get_by(Bookie.Method, params)
  end

  def create_method(changeset, repo) do
    repo.insert(changeset)
  end

  def update_method(changeset, repo) do
    repo.insert(changeset)
  end

  def delete_method(changeset, repo) do
    repo.delete(changeset)
  end

  def parse_method_with_users(method) when method in [nil, []] do
    {:error, "method not found"}
  end

  def parse_method_with_users(method) do
    users = User.parse_user_for_method(method.users)

    parsed_user = %{
      id: method.id,
      function: method.function,
      method: method.method,
      users: users
    }

    {:ok, parsed_user}
  end
end
