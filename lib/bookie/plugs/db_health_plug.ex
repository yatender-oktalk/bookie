defmodule Plugs.DBHealthPlug do
  import Plug.Conn

  def init(defaults) do
    defaults
  end

  def call(conn, _defaults) do
    case Bookie.Health.Controller.mysql_health() do
      :down ->
        conn
        |> send_resp(503, Poison.encode!(%{message: "database not available"}))
        |> halt

      _ ->
        conn |> assign(:health, "perfect!")
    end
  end
end
