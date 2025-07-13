defmodule Talar.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :username, :string
    field :email, :string
    field :status, Ecto.Enum, values: [offline: 0, online: 1, away: 2], default: :offline

    timestamps(type: :utc_datetime)
  end

  def online?(%__MODULE__{} = user), do: user.status == :online

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :status])
    |> validate_required([:username, :email, :status])
    |> unique_constraint(:username,
      message: "Username is already taken",
      name: :users_username_index)
    #|> validate_length(:password, min: 6)
  end
end
