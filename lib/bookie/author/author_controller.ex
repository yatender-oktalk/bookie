defmodule Bookie.Author.Controller do
  use Bookie, :controller

  alias Bookie.Author.{
    Model
  }

  def index(conn, params) do
    send_resp(conn, Model.get_author(params["id"]))
  end

  def create(conn, params) do
    send_resp(conn, Model.create_author(conn.body_params))
  end

  def update(conn, params) do
    send_resp(conn, Model.update_author(params, conn.body_params))
  end

  def delete(conn, params) do
    send_resp(conn, Model.delete_author(params["id"]))
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
