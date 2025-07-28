defmodule Talar.Chats.Chat do
  use Ecto.Schema
  import Ecto.Changeset

  alias Talar.Chats.ChatUser

  schema "chats" do

    field :user_id_1, :id
    field :user_id_2, :id

    has_many :chat_users, ChatUser
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(chat, attrs) do
    chat
    |> cast(attrs, [])
    |> validate_required([])
  end
end
