defmodule Bookie.AuthorBook do
  @moduledoc """
  Module to map author and books
  to map author with books preloaded structs with associations are required so that
  two way binding can be done otherwise it'll not work as expected becasue associasion
  can not be updated via that process.
  """
  use Bookie, :model

  use Ecto.Schema

  alias Bookie.Author, as: Author
  alias Bookie.Book, as: Book

  schema "authors_books" do
    belongs_to(:authors, Author, type: :binary_id, foreign_key: :author_id)
    belongs_to(:books, Book, type: :binary_id, foreign_key: :book_id)
  end

  @doc """
  This module is getting used to map the user with the method
  Here we are takeing the all previous books authored by author
  and here in author and book module we are expecting the preloaded data
  of all associations with books and author and then we are mapping it with new method.
  as on update we are deleting all previous associations so have to map new ones with older
  ones and update the reference.

  same we will do with delete mapping there instead of adding into the list we'll just
  delete from the list.
  """
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
