defmodule Bookie.Method.Controller do
  use Bookie, :controller

  alias Bookie.Method.{
    Model
  }

  def index(conn, params) do
    send_resp(conn, Model.get_method(params["id"]))
  end

  def create(conn, params) do
    send_resp(conn, Model.create_method(conn.body_params))
  end

  def update(conn, params) do
    send_resp(conn, Model.update_method(params, conn.body_params))
  end

  def delete(conn, params) do
    send_resp(conn, Model.delete_method(params["id"]))
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
