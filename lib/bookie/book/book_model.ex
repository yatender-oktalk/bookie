defmodule Bookie.Book.Model do
  use Bookie, :model

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "books" do
    field(:name, :string, required: true)
    field(:description, :string, default: "")
    timestamps()

    many_to_many(:authors, Bookie.Author.Model, join_through: "authors_books", on_replace: :delete)
  end

  def get_book(book_list) do
    query =
      from(u in Bookie.Book.Model,
        where: u.id in ^book_list,
        select: u
      )

    Repo.all(query)
  end

  def create_book(_params) do
    # validate with changeset
  end

  def update_book(_id, _params) do
    # check chengeset
  end

  def delete_book(_id) do
    # delete book
  end
end
