defmodule Plugs.AuthPlug do
  @moduledoc false
  import Plug.Conn
  @allowed_without_auth ["GET"]

  def init(defaults) do
    defaults
  end

  def call(conn, _defaults) do
    # qf = fetch_query_params(conn)
    %Plug.Conn{req_headers: headers} = conn
    headers = Map.new(headers)

    # fetch id and password
    # id and password can also be used
    user_id = headers["id"]
    password = headers["password"]

    case conn.method in @allowed_without_auth or conn.assigns[:is_no_auth_path] do
      true ->
        conn

      _ ->
        case {is_nil(user_id), is_nil(password)} do
          {true, true} ->
            conn
            |> send_resp(
              401,
              Poison.encode!(%{message: "Auth Error, please put id and password in header"})
            )
            |> halt

          {true, false} ->
            conn
            |> send_resp(401, Poison.encode!(%{message: "Auth Error, please put id in header"}))
            |> halt

          {false, true} ->
            conn
            |> send_resp(
              401,
              Poison.encode!(%{message: "Auth Error, please put password in header"})
            )
            |> halt

          _ ->
            # if POST, PUT, DELETE then only verify credentials
            case Bookie.User.check_user_credentials(
                   %{"id" => user_id, "password" => password},
                   Bookie.Repo
                 ) do
              {:ok, user} ->
                conn |> assign(:user, user)

              {:error, _} ->
                conn
                |> send_resp(
                  401,
                  Poison.encode!(%{message: "Auth Error, please verify credentials"})
                )
                |> halt
            end
        end
    end
  end
end
