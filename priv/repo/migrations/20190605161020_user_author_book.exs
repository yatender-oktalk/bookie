defmodule Bookie.Repo.Migrations.UserAuthorBook do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:name, :string, null: false)
      add(:hashed_password, :string, null: false)
      timestamps()
    end

    create(unique_index(:users, [:name]))

    create table(:authors, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:firstname, :string, required: true)
      add(:lastname, :string, default: "")
      timestamps()
    end

    create table(:books, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:name, :string, null: false)
      add(:description, :string, default: "")
      timestamps()
    end

    create table(:methods, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:function, :string, null: false)
      add(:method, :string, null: false)
      timestamps()
    end

    create table(:authors_books, primary_key: false) do
      add(:book_id, references("books", type: :uuid, on_delete: :delete_all))
      add(:author_id, references("authors", type: :uuid, on_delete: :delete_all))
    end

    create(index(:authors_books, [:book_id]))
    create(index(:authors_books, [:author_id]))

    create(
      unique_index(:authors_books, [:book_id, :author_id], name: :book_id_author_id_unique_index)
    )

    create table(:users_methods, primary_key: false) do
      add(:user_id, references("users", type: :uuid, on_delete: :delete_all))
      add(:method_id, references("methods", type: :uuid, on_delete: :delete_all))
    end

    create(index(:users_methods, [:method_id]))
    create(index(:users_methods, [:user_id]))

    create(
      unique_index(:users_methods, [:user_id, :method_id], name: :user_id_method_id_unique_index)
    )
  end

  def down do
    drop(table(:users))
    drop(table(:authors))
    drop(table(:books))
    drop(table(:methods))
    drop(table(:users_methods))
    drop(table(:authors_books))
  end
end
