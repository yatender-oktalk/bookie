defmodule Bookie.Health.Controller do
  @moduledoc """
  controller module for health check
  """
  use Bookie, :controller

  @doc """
  method to check all integrations module and their health check
  In furutre alerting services like slack/flock/email/sms can
  also be integrated at this single place itself
  """
  def index(conn, _params) do
    data = %{
      version: Application.spec(:bookie, :vsn) |> to_string(),
      application_status: "health is fine, application is up and accessible",
      database_status: db_health()
    }

    send_resp(conn, {:ok, data})
  end

  @doc """
  method to do raw query to db so that we can get status of it and take desicions of application health
    Note:
      * This method will return :down when database is not available
      * This method will return :up when database is available
  """
  def db_health() do
    try do
      {:ok, _map} = Ecto.Adapters.SQL.query(Bookie.Repo, "SELECT 1", [])
      :up
    rescue
      _e in DBConnection.ConnectionError -> :down
    end
  end

  @doc """
  Generic method to send response to client in JSON format
  """
  defp send_resp(conn, res) do
    {status, response} =
      case res do
        {:ok, resp} -> {HTTPCodes.ok(), resp}
        {:error, resp} -> {HTTPCodes.bad_request(), resp}
      end

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(%{resp: response}))
  end
end
