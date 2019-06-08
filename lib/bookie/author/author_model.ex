defmodule Bookie.Author.Model do
  use Bookie, :model

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "authors" do
    field(:firstname, :string, required: true)
    field(:lastname, :string, default: "")
    timestamps()

    many_to_many(:books, Bookie.Book.Model, join_through: "authors_books", on_replace: :delete)
  end

  def get_author(author_list) do
    query =
      from(u in Bookie.Author.Model,
        where: u.id in ^author_list,
        select: u
      )

    Repo.all(query)
  end

  def create_author(_params) do
    # validate with changeset
  end

  def update_author(_id, _params) do
    # check chengeset
  end

  def delete_author(_id) do
    # delete Author
  end
end
