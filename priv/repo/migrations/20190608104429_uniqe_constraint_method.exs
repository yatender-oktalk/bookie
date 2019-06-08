defmodule Bookie.Repo.Migrations.UniqeConstraintMethod do
  use Ecto.Migration

  def up do
    create(unique_index(:methods, [:function, :method], name: :function_method_uniqe))
  end
end
