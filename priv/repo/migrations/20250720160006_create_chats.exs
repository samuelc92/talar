defmodule Talar.Repo.Migrations.CreateChats do
  use Ecto.Migration

  def change do
    create table(:chats) do
      add :user_id_1, references(:users, on_delete: :nothing)
      add :user_id_2, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:chats, [:user_id_1])
    create index(:chats, [:user_id_2])
  end
end
