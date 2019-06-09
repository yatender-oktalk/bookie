defmodule Plugs.NoAuthPathPlug do
  @moduledoc false
  import Plug.Conn

  def init(defaults) do
    defaults
  end

  def call(conn, _defaults) do
    case no_auth_path?({conn.method, conn.request_path}) do
      true ->
        conn |> assign(:is_no_auth_path, true)

      _ ->
        conn |> assign(:is_no_auth_path, false)
    end
  end

  def no_auth_path?({method, path}) do
    no_auth_paths = [{"POST", "/api/users/"}]
    Enum.member?(no_auth_paths, {method, path})
  end
end
