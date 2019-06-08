defmodule Bookie.Method.Controller do
  use Bookie, :controller

  alias Bookie.Method.Model, as: Method

  def index(conn, params) do
    send_resp(conn, Method.get_method(params["id"]))
  end

  def create(conn, %{"method" => params}) do
    changeset = Method.changeset(%Method{}, params)

    {code, status, msg} =
      case Method.create_method(changeset, Bookie.Repo) do
        {:ok, changeset} ->
          method_resp = %{
            id: changeset.id,
            function: changeset.function,
            method: changeset.method
          }

          {201, "success", method_resp}

        {:error, changeset} ->
          error =
            Ecto.Changeset.traverse_errors(
              changeset,
              &BookieWeb.ErrorHelpers.translate_error/1
            )

          {400, "failed", error}
      end

    send_response(conn, code, status, msg)
  end

  def update(conn, %{"id" => id}) do
    body_params = conn.body_params

    {code, status, msg} =
      with method_struct <- Method.get_method(id),
           changeset <- Method.changeset(method_struct, body_params),
           {:ok, updated_changeset} <- Method.update_method(changeset, Repo) do
        method_resp = %{
          id: updated_changeset.id,
          function: updated_changeset.function,
          method: updated_changeset.method
        }

        {201, "success", method_resp}
      else
        {:error, changeset} ->
          error =
            Ecto.Changeset.traverse_errors(changeset, &BookieWeb.ErrorHelpers.translate_error/1)

          {400, "failed", error}
      end

    send_response(conn, code, status, msg)
  end

  def delete(conn, params) do
    send_resp(conn, Method.delete_method(params["id"]))
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

  def send_response(conn, code, status, msg) do
    response = %{
      status: status,
      resp: msg
    }

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(code, Poison.encode!(response))
  end
end
