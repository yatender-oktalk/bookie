defmodule Bookie.User.Controller do
  use Bookie, :controller

  alias Bookie.User.Model, as: User

  def index(conn, params) do
    send_resp(conn, User.get_user(params["id"]))
  end

  def get_user(conn, %{"id" => id}) do
    send_resp(conn, User.get_user(id))
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

    case User.create_user(changeset, Bookie.Repo) do
      {:ok, changeset} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(
          201,
          Poison.encode!(%{
            resp:
              "User created successfully, please start using apis with username and password in header!"
          })
        )

      {:error, changeset} ->
        error =
          Ecto.Changeset.traverse_errors(changeset, &BookieWeb.ErrorHelpers.translate_error/1)

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(400, Poison.encode!(error))
    end
  end

  def update(conn, params) do
    send_resp(conn, User.update_user(params, conn.body_params))
  end

  def delete(conn, params) do
    send_resp(conn, User.delete_user(params["id"]))
  end

  defp send_resp(conn, res) do
    {status, response} =
      case res do
        {:ok, resp} -> {200, resp}
        {:error, resp} -> {400, resp}
      end

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Poison.encode!(%{resp: response}))
  end
end
