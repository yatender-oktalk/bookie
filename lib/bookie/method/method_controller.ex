defmodule Bookie.Method.Controller do
  use Bookie, :controller

  alias Bookie.Method, as: Method

  def index(conn, params) do
    limit = params["limit"] || 20
    offset = params["offset"] || 0

    methods = Method.get_methods(limit, offset)
    {code, status, msg} = {HTTPCodes.ok(), "success", methods}

    send_response(conn, code, status, msg)
  end

  def get_method(conn, %{"id" => id}) do
    method = Method.get_method(id)

    {code, status, msg} =
      case Method.parse_method_for_model(method) do
        {:ok, method} ->
          {HTTPCodes.ok(), "success", method}

        {:error, error} ->
          {HTTPCodes.bad_request(), "failed", error}
      end

    send_response(conn, code, status, msg)
  end

  def create(conn, %{"method" => params}) do
    changeset = Method.changeset(%Method{}, params)

    {code, status, msg} =
      case Method.create_method(changeset, Bookie.Repo) do
        {:ok, changeset} ->
          {201, "success", changeset}

        {:error, changeset} ->
          error =
            Ecto.Changeset.traverse_errors(
              changeset,
              &BookieWeb.ErrorHelpers.translate_error/1
            )

          {HTTPCodes.bad_request(), "failed", error}
      end

    send_response(conn, code, status, msg)
  end

  def update(conn, %{"id" => id}) do
    body_params = conn.body_params

    {code, status, msg} =
      with method_struct <- Method.get_method(id),
           changeset <- Method.changeset(method_struct, body_params),
           {:ok, _changeset} <- Method.update_method(changeset, Repo) do
        {HTTPCodes.ok(), "success", "method updated"}
      else
        {:error, changeset} ->
          error =
            Ecto.Changeset.traverse_errors(changeset, &BookieWeb.ErrorHelpers.translate_error/1)

          {HTTPCodes.bad_request(), "failed", error}
      end

    send_response(conn, code, status, msg)
  end

  def delete(conn, params) do
    method = Method.get_method(params["id"])

    {code, status, msg} =
      case Method.delete_method(method, Bookie.Repo) do
        {:ok, _ch} ->
          {HTTPCodes.ok(), "success", "success delete"}

        {:error, changeset} ->
          {HTTPCodes.bad_request(), "error", changeset}
      end

    send_response(conn, code, status, msg)
  end

  def method_users(conn, params) do
    method = Method.get_method_users(params["id"])

    {code, status, msg} =
      case Method.parse_method_with_users(method) do
        {:ok, method} ->
          {HTTPCodes.ok(), "success", method}

        {:error, error} ->
          {HTTPCodes.bad_request(), "failed", error}
      end

    send_response(conn, code, status, msg)
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
