defmodule Bookie.Book do
  use Bookie, :model
  alias Bookie.{Author, Book}

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "books" do
    field(:name, :string, required: true)
    field(:description, :string, default: "")
    timestamps()

    many_to_many(:authors, Bookie.Author, join_through: "authors_books", on_replace: :delete)
  end

  @required_fields ~w(name description)
  @optional_fields ~w(description)

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_required(:name)
  end

  def get_book(id) do
    Repo.get!(Book, id)
  end

  def get_books(limit, offset) do
    query =
      from(u in Book,
        limit: ^limit,
        offset: ^offset,
        select: %{
          name: u.name,
          description: u.description,
          inserted_at: u.inserted_at,
          updated_at: u.updated_at,
          id: u.id
        }
      )

    Repo.all(query)
  end

  def get_book_authors(id) do
    Repo.get(Book, id) |> Repo.preload(:authors)
  end

  def create_book(changeset, repo) do
    repo.insert(changeset)
  end

  def update_book(changeset, repo) do
    repo.update(changeset)
  end

  def delete_book(changeset, repo) do
    repo.delete(changeset)
  end

  def book_parser_no_author(books) when books in [nil, []] do
    []
  end

  def book_parser_no_author(books) do
    books |> Enum.map(&extract_book_data/1)
  end

  def extract_book_data(book) do
    %{
      id: book.id,
      name: book.name,
      description: book.description,
      inserted_at: book.inserted_at,
      updated_at: book.updated_at
    }
  end

  def parse_book_with_authors(book) when book in [nil, [], %{}] do
    {:error, "book not found"}
  end

  def parse_book_with_authors(book) do
    parsed_authors = Author.get_author_data(book.authors)
    book_data = extract_book_data(book)
    {:ok, Map.put(book_data, :authors, parsed_authors)}
  end

  def parse_book_for_model(nil) do
    {:error, "book not found"}
  end

  def parse_book_for_model(book) do
    {:ok, extract_book_data(book)}
  end
end
