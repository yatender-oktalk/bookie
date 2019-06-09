defmodule Plugs.NoAuthPathPlug do
  @moduledoc """
  NoAuthPathPlug module is for predefined paths which are allowed without authentication
  paths like User Creation
  """
  import Plug.Conn
  @non_auth_paths Application.get_env(:bookie, :env)[:non_auth_paths]
  def init(defaults) do
    defaults
  end

  @doc """
  we are assigning is_no_auth_path true || false based on the path validation
  if path falls into category where we don't check for auth
  """
  def call(conn, _defaults) do
    case no_auth_path?({conn.method, conn.request_path}) do
      true ->
        conn |> assign(:is_no_auth_path, true)

      _ ->
        conn |> assign(:is_no_auth_path, false)
    end
  end

  @doc """
  no_auth_path? is for checking a particular request that it is configured by us for non-auth
  for e.g. User Signup flow should not check for auth because user is not created till now so if we check
  user signup request for auth it'll always fail so we are adding our user signup path in no auth
  and assinging that key into our conn and it'll override anywhere in request flow and will not check this request for authorization
  we can always extend this by adding more keys and paths

  in case want to add more paths here just add into env config :non_auth_paths key
  """
  def no_auth_path?({method, path}) do
    Enum.member?(@non_auth_paths, {method, path})
  end
end
