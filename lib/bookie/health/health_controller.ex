defmodule Bookie.Health.Controller do
  @moduledoc """
  controller module for health check
  """
  use Bookie, :controller

  def index(conn, _params) do
    send_resp(conn, {:ok, "health is fine"})
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
end
