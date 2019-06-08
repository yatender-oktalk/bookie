defmodule Bookie.AuthorBooks.Model do
  use Bookie, :model

  use Ecto.Schema

  alias Bookie.Author.Model, as: Author
  alias Bookie.Book.Model, as: Book

  schema "authors_books" do
    belongs_to(:authors, Author, type: :binary_id)
    belongs_to(:books, Book, type: :binary_id)
  end
end
