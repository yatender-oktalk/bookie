defmodule Bookie.AuthorBook do
  use Bookie, :model

  use Ecto.Schema

  alias Bookie.Author, as: Author
  alias Bookie.Book, as: Book

  schema "authors_books" do
    belongs_to(:authors, Author, type: :binary_id, foreign_key: :author_id)
    belongs_to(:books, Book, type: :binary_id, foreign_key: :book_id)
  end

  def map_author_book(author, books) do
    author_books = author.books

    author
    |> Repo.preload(:books)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:books, author_books ++ [books])
    |> Repo.update()
  end

  def delete_author_book(author, books) do
    author_books = author.books

    author
    |> Repo.preload(:books)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:books, author_books -- [books])
    |> Repo.update()
  end
end
