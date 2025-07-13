defmodule Talar.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string, null: false
      add :email, :string, null: false
      add :status, :integer, null: false, default: 0

      timestamps(type: :utc_datetime)
    end

    create index(:users, [:username])
    create index(:users, [:status])
  end
end
