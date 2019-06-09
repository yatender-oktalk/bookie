defmodule Bookie.Health.Controller do
  @moduledoc """
  controller module for health check
  """
  use Bookie, :controller

  def index(conn, _params) do
    data = %{
      version: Application.spec(:bookie, :vsn) |> to_string(),
      application_health: "health is fine, application is up and accessible",
      database_health: mysql_health()
    }

    send_resp(conn, {:ok, data})
  end

  defp send_resp(conn, res) do
    {status, response} =
      case res do
        {:ok, resp} -> {200, resp}
        {:error, resp} -> {400, resp}
      end

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(%{resp: response}))
  end

  def mysql_health() do
    try do
      {:ok, _map} = Ecto.Adapters.SQL.query(Bookie.Repo, "SELECT 1", [])
      :up
    rescue
      _e in DBConnection.ConnectionError -> :down
    end
  end
end
