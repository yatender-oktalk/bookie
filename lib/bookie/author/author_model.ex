defmodule Bookie.Author do
  use Bookie, :model

  alias Bookie.Author, as: Author
  alias Bookie.Book, as: Book

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "authors" do
    field(:firstname, :string, required: true)
    field(:lastname, :string, default: "")
    timestamps()

    many_to_many(:books, Bookie.Book, join_through: "authors_books", on_replace: :delete)
  end

  @required_fields ~w(firstname lastname)
  @optional_fields ~w(lastname)

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_required(:firstname)
    |> validate_length(:firstname, min: 2)
    |> IO.inspect()
  end

  def create_author(changeset, repo) do
    changeset |> repo.insert()
  end

  def get_authors(limit, offset) do
    query =
      from(u in Author,
        limit: ^limit,
        offset: ^offset,
        select: %{
          firstname: u.firstname,
          lastname: u.lastname,
          inserted_at: u.inserted_at,
          updated_at: u.updated_at,
          id: u.id
        }
      )

    Repo.all(query)
  end

  def update_author(changeset, repo) do
    # check chengeset
    changeset |> repo.update()
  end

  def delete_author(changeset, repo) do
    repo.delete(changeset)
  end

  @doc """
  This method will return user based on it's id
  This method will raise error in case data not found
  """
  def get_author!(id) do
    Repo.get!(Author, id)
  end

  def parse_author_no_book(author) when author in [nil, "", %{}] do
    {:error, "author not found"}
  end

  def parse_author_no_book(author) do
    {:ok, extract_author_data(author)}
  end

  def extract_author_data(author) do
    %{
      id: author.id,
      firstname: author.firstname,
      lastname: author.lastname,
      inserted_at: author.inserted_at,
      updated_at: author.updated_at
    }
  end

  def parse_author(author) do
    parsed_books = Book.book_parser_no_author(author.books)
    author = extract_author_data(author)
    {:ok, Map.put(author, :books, parsed_books)}
  end

  def get_author_data(authors) when authors in [nil, %{}, []] do
    []
  end

  def get_author_data(authors) do
    authors |> Enum.map(&extract_author_data/1)
  end
end
