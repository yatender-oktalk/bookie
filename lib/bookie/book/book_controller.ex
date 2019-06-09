defmodule Bookie.Book.Controller do
  use Bookie, :controller

  alias Bookie.Book

  def index(conn, params) do
    limit = params["limit"] || 20
    offset = params["offset"] || 0

    books = Book.get_books(limit, offset)
    {code, status, msg} = {HTTPCodes.ok(), "success", books}

    send_response(conn, code, status, msg)
  end

  def get_book(conn, %{"id" => id}) do
    book = Book.get_book(id)

    {code, status, msg} =
      case Book.parse_book_for_model(book) do
        {:ok, book} ->
          {HTTPCodes.ok(), "success", book}

        {:error, error} ->
          {HTTPCodes.bad_request(), "failed", error}
      end

    send_response(conn, code, status, msg)
  end

  def create(conn, %{"book" => params}) do
    changeset = Book.changeset(%Book{}, params)

    {code, status, msg} =
      case Book.create_book(changeset, Bookie.Repo) do
        {:ok, changeset} ->
          book = %{
            name: changeset.name,
            description: changeset.description,
            inserted_at: changeset.inserted_at,
            updated_at: changeset.updated_at,
            id: changeset.id
          }

          {201, "success", book}

        {:error, changeset} ->
          error =
            Ecto.Changeset.traverse_errors(
              changeset,
              &BookieWeb.ErrorHelpers.translate_error/1
            )

          {HTTPCodes.bad_request(), "failed", error}
      end

    send_response(conn, code, status, msg)
  end

  def update(conn, %{"id" => id}) do
    body_params = conn.body_params

    {code, status, msg} =
      with book_struct <- Book.get_book(id),
           changeset <- Book.changeset(book_struct, body_params),
           {:ok, changeset} <- Book.update_book(changeset, Bookie.Repo) do
        updated_book = Book.extract_book_data(changeset)
        {HTTPCodes.ok(), "success", updated_book}
      else
        {:error, changeset} ->
          error =
            Ecto.Changeset.traverse_errors(changeset, &BookieWeb.ErrorHelpers.translate_error/1)

          {HTTPCodes.bad_request(), "failed", error}
      end

    send_response(conn, code, status, msg)
  end

  def delete(conn, params) do
    book = Book.get_book(params["id"])

    {code, status, msg} =
      case Book.delete_book(book, Bookie.Repo) do
        {:ok, _ch} ->
          {HTTPCodes.ok(), "success", "success delete"}

        {:error, changeset} ->
          {HTTPCodes.bad_request(), "error", changeset}
      end

    send_response(conn, code, status, msg)
  end

  def book_authors(conn, params) do
    book = Book.get_book_authors(params["id"])

    {code, status, msg} =
      case Book.parse_book_with_authors(book) do
        {:ok, book} ->
          {HTTPCodes.ok(), "success", book}

        {:error, error} ->
          {HTTPCodes.bad_request(), "failed", error}
      end

    send_response(conn, code, status, msg)
  end

  def send_response(conn, code, status, msg) do
    response = %{
      status: status,
      resp: msg
    }

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(code, Poison.encode!(response))
  end
end
