defmodule Bookie.Author.Controller do
  use Bookie, :controller

  alias Bookie.{Author, Book, AuthorBook}

  def index(conn, params) do
    limit = params["limit"] || 20
    offset = params["offset"] || 0

    authors = Author.get_authors(limit, offset)
    {code, status, msg} = {HTTPCodes.ok(), "success", authors}

    send_response(conn, code, status, msg)
  end

  def get_author(conn, %{"id" => id}) do
    author = Author.get_author!(id)

    {code, status, msg} =
      case Author.parse_author_no_book(author) do
        {:ok, author} ->
          parsed_author = Author.extract_author_data(author)

          {HTTPCodes.ok(), "success", parsed_author}

        {:error, error} ->
          {HTTPCodes.bad_request(), "failed", error}
      end

    send_response(conn, code, status, msg)
  end

  def create(conn, %{"author" => params}) do
    changeset = Author.changeset(%Author{}, params)

    {code, status, msg} =
      case Author.create_author(changeset, Bookie.Repo) do
        {:ok, changeset} ->
          parsed_author = Author.extract_author_data(changeset)

          {201, "success", parsed_author}

        {:error, changeset} ->
          error =
            Ecto.Changeset.traverse_errors(changeset, &BookieWeb.ErrorHelpers.translate_error/1)

          {HTTPCodes.bad_request(), "failed", error}
      end

    send_response(conn, code, status, msg)
  end

  @doc """
  API to update author
  sample request body
  {
    "lastname": "lastname3",
    "firstname": "author3"
  }
  PUT /authors/:id
  """
  def update(conn, %{"id" => id}) do
    # will put author struct here
    author_struct = Author.get_author!(id)
    body_params = conn.body_params

    author_id = author_struct.id

    {code, status, msg} =
      with true <- String.equivalent?(author_id, id),
           changeset <- Author.changeset(author_struct, body_params),
           {:ok, changeset} <- Author.update_author(changeset, Bookie.Repo) do
        parsed_author = Author.extract_author_data(changeset)
        {HTTPCodes.ok(), "success", parsed_author}
      else
        false ->
          {HTTPCodes.no_permission(), "failed", "author not allowed to update this author's data"}

        {:error, changeset} ->
          {HTTPCodes.bad_request(), "failed", changeset}
      end

    send_response(conn, code, status, msg)
  end

  def delete(conn, params) do
    author = Author.get_author!(params["id"])

    {code, status, msg} =
      case Author.delete_author(author, Bookie.Repo) do
        {:ok, _ch} ->
          {HTTPCodes.ok(), "success", "success delete"}

        {:error, changeset} ->
          error =
            Ecto.Changeset.traverse_errors(changeset, &BookieWeb.ErrorHelpers.translate_error/1)

          {HTTPCodes.bad_request(), "error", error}
      end

    send_response(conn, code, status, msg)
  end

  def author_book_add(conn, %{"id" => id, "book_id" => book_id}) do
    author = Author.get_author!(id) |> Bookie.Repo.preload(:books)
    book = Book.get_book(book_id) |> Bookie.Repo.preload(:authors)

    {code, status, msg} =
      case AuthorBook.map_author_book(author, book) do
        {:ok, _author} ->
          {HTTPCodes.ok(), "success", "Successfully Mapped book with author"}

        {:error, _changeset} ->
          {HTTPCodes.bad_request(), "failed", "failed to map book with author"}
      end

    send_response(conn, code, status, msg)
  end

  def author_book_remove(conn, %{"id" => id, "book_id" => book_id}) do
    # get author with books
    author = Author.get_author!(id) |> Bookie.Repo.preload(:books)
    book = Book.get_book(book_id) |> Bookie.Repo.preload(:authors)

    {code, status, msg} =
      case AuthorBook.delete_author_book(author, book) do
        {:ok, _author} ->
          {HTTPCodes.ok(), "success", "Successfully deleted book from author"}

        {:error, _changeset} ->
          {HTTPCodes.bad_request(), "failed", "failed to deleted book with author"}
      end

    send_response(conn, code, status, msg)
  end

  def author_books(conn, %{"id" => id}) do
    author = Author.get_author!(id) |> Bookie.Repo.preload(:books)

    {code, status, msg} =
      case Author.parse_author(author) do
        {:ok, author} ->
          {HTTPCodes.ok(), "success", author}

        {:error, error} ->
          {HTTPCodes.bad_request(), "failed", error}
      end

    send_response(conn, code, status, msg)
  end

  defp send_response(conn, code, status, msg) do
    response = %{
      status: status,
      resp: msg
    }

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(code, Poison.encode!(response))
  end
end
