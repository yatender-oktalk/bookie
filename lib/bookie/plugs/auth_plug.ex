defmodule Plugs.AuthPlug do
  @moduledoc false
  import Plug.Conn
  @allowed_without_auth Application.get_env(:bookie, :env)[:non_auth_req_type]

  def init(defaults) do
    defaults
  end

  def call(conn, _defaults) do
    # qf = fetch_query_params(conn)
    %Plug.Conn{req_headers: headers} = conn
    headers = Map.new(headers)

    # fetch id and password from headers
    # id and password can also be used but right now id and password is getting used in case we decide
    # to remove unique constraint from user name
    user_id = headers["id"]
    password = headers["password"]

    # Here we are checking if request type is in non_auth_req_type which is ["GET"] right now
    # or if there is any path which is allowed to bypass by previous plug Plugs.NoAuthPathPlug
    # if any condition matches i.e. if request type is GET
    # or path is no_auth_path then we will not check for authorization
    # and directly send the request for further operations and request will be served without authentication
    case conn.method in @allowed_without_auth or conn.assigns[:is_no_auth_path] do
      true ->
        conn

      _ ->
        # Here we are checking for validation of user_id and password and showing diffrent-2 messages and returning
        # via  HTTPCodes.unauthorized http call and a message to tell user what went wrong
        case {is_nil(user_id), is_nil(password)} do
          {true, true} ->
            conn
            |> send_resp(
              HTTPCodes.unauthorized(),
              Poison.encode!(%{message: "Auth Error, please put id and password in header"})
            )
            |> halt

          {true, false} ->
            conn
            |> send_resp(
              HTTPCodes.unauthorized(),
              Poison.encode!(%{message: "Auth Error, please put id in header"})
            )
            |> halt

          {false, true} ->
            conn
            |> send_resp(
              HTTPCodes.unauthorized(),
              Poison.encode!(%{message: "Auth Error, please put password in header"})
            )
            |> halt

          _ ->
            # If POST, PUT, DELETE then only verify credentials
            case Bookie.User.check_user_credentials(
                   %{"id" => user_id, "password" => password},
                   Bookie.Repo
                 ) do
              {:ok, user} ->
                # Once our authorization module says ok for auth then we assign user details into the headers so that it can be used
                # further. Requests like User updation/deletion etc when one user is trying to update any other user's credentials
                conn |> assign(:user, user)

              {:error, _} ->
                conn
                |> send_resp(
                  HTTPCodes.unauthorized(),
                  Poison.encode!(%{message: "Auth Error, please verify credentials"})
                )
                |> halt
            end
        end
    end
  end
end
