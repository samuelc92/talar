defmodule Talar.Chats.ChatUser do
  use Ecto.Schema
  import Ecto.Changeset

  alias Talar.Accounts.User
  alias Talar.Chats.Chat

  schema "chat_users" do

    field :message, :string

    belongs_to :chat, Chat
    belongs_to :user, User
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(chat_user, attrs) do
    chat_user
    |> cast(attrs, [:message, :user_id, :chat_id])
    |> validate_required([:message, :user_id, :chat_id])
  end
end
