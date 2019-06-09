defmodule Bookie.User.Controller do
  use Bookie, :controller

  alias Bookie.User, as: User
  alias Bookie.Method, as: Method
  alias Bookie.UserMethod, as: UserMethod

  def index(conn, params) do
    limit = params["limit"] || 20
    offset = params["offset"] || 0

    users = User.get_users(limit, offset)
    {code, status, msg} = {200, "success", users}

    send_response(conn, code, status, msg)
  end

  def get_user(conn, %{"id" => id}) do
    user = User.get_user(id)

    {code, status, msg} =
      case User.parse_user_no_method(user) do
        {:ok, user} ->
          {200, "success", user}

        {:error, error} ->
          {400, "failed", error}
      end

    send_response(conn, code, status, msg)
  end

  @doc """
  sample request to create user
  POST {hostname}/api/users
  request body:

  {
    "user": {
      "name": "yatender",
      "password": "password"
    }
  }
  """
  def create(conn, %{"user" => params}) do
    changeset = User.changeset(%User{}, params)

    {code, status, msg} =
      case User.create_user(changeset, Bookie.Repo) do
        {:ok, changeset} ->
          user_resp = %{
            id: changeset.id,
            name: changeset.name,
            password: changeset.password
          }

          {201, "success", user_resp}

        {:error, changeset} ->
          error =
            Ecto.Changeset.traverse_errors(changeset, &BookieWeb.ErrorHelpers.translate_error/1)

          {400, "failed", error}
      end

    send_response(conn, code, status, msg)
  end

  # id should be same which we are getting in header
  # after validation we will put user struct in headers
  def update(conn, %{"id" => id}) do
    # will put user struct here
    # we can override also if we create admin user
    user_struct = conn.assigns[:user]
    body_params = conn.body_params

    user_id = user_struct.id

    {code, status, msg} =
      with true <- String.equivalent?(user_id, id),
           changeset <- User.changeset(user_struct, body_params),
           {:ok, changeset_updated} <- User.update(changeset, Bookie.Repo) do
        user_resp = %{
          id: changeset_updated.id,
          name: changeset_updated.name,
          password: changeset_updated.password
        }

        {200, "success", user_resp}
      else
        false ->
          {403, "failed", "user not allowed to update this user's data"}

        {:error, changeset} ->
          error =
            Ecto.Changeset.traverse_errors(changeset, &BookieWeb.ErrorHelpers.translate_error/1)

          {400, "failed", error}
      end

    send_response(conn, code, status, msg)
  end

  def delete(conn, %{"id" => id}) do
    user = User.get_user!(id)

    {code, status, msg} =
      case User.delete_user(user, Bookie.Repo) do
        {:ok, _ch} ->
          {200, "success", "success delete"}

        {:error, changeset} ->
          error =
            Ecto.Changeset.traverse_errors(changeset, &BookieWeb.ErrorHelpers.translate_error/1)

          {400, "error", error}
      end

    send_response(conn, code, status, msg)
  end

  def user_method_add(conn, params) do
    user = User.get_user_methods(params["id"])
    method = Method.get_method_users(params["method_id"])

    {code, status, msg} =
      case UserMethod.map_user_method(user, method) do
        {:ok, _user} ->
          {200, "success", "Successfully Mapped method with user"}

        {:error, _changeset} ->
          {400, "failed", "failed to map metho with user"}
      end

    send_response(conn, code, status, msg)
  end

  def user_method_remove(conn, params) do
    # get user with methods
    user = User.get_user_methods(params["id"])
    # get method
    method = Method.get_method(params["method_id"])
    # remove method with the user

    {code, status, msg} =
      case UserMethod.delete_user_method(user, method) do
        {:ok, _user} ->
          {200, "success", "Successfully delete method from user"}

        {:error, _changeset} ->
          {400, "failed", "failed to delete method with user"}
      end

    send_response(conn, code, status, msg)
  end

  def user_methods(conn, params) do
    user = User.get_user_methods(params["id"])

    {code, status, msg} =
      case User.parse_user(user) do
        {:ok, user} ->
          {200, "success", user}

        {:error, error} ->
          {400, "failed", error}
      end

    send_response(conn, code, status, msg)
  end

  defp send_response(conn, code, status, msg) do
    response = %{
      status: status,
      resp: msg
    }

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(code, Poison.encode!(response))
  end
end
