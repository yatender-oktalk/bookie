defmodule Bookie.Author.Router do
  use Bookie, :router

  alias Bookie.Author.{
    Controller
  }

  get("/", Controller, :index)
  post("/", Controller, :create)
  get("/:id", Controller, :get_author)
  put("/:id", Controller, :update)
  delete("/:id", Controller, :delete)
  get("/:id/books", Controller, :author_books)
  put("/:id/books/:book_id", Controller, :author_book_add)
  delete("/:id/books/:book_id", Controller, :author_book_remove)
end
