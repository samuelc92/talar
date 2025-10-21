defmodule Talar.Chats do
  @moduledoc """
  The Chats context.
  """

  import Ecto.Query, warn: false
  alias Talar.Repo

  alias Talar.Chats.{Chat, ChatUser}

  @doc """
  Returns the list of chats.

  ## Examples

      iex> list_chats()
      [%Chat{}, ...]

  """
  def list_chats do
    Repo.all(Chat)
  end

  def get_chat_by_user_preloaded(current_user_id, user_id) do
    Repo.one(
      from c in Chat,
        where:
          (c.user_id_1 == ^current_user_id and c.user_id_2 == ^user_id) or
            (c.user_id_1 == ^user_id and c.user_id_2 == ^current_user_id),
        preload: [:chat_users]
    )
  end

  def get_chat_preloaded!(id) do
    Repo.get!(Chat, id)
  end

  def get_chat_users_by_chat_id(chat_id) do
    Repo.all_by(ChatUser, chat_id: chat_id)
  end

  @doc """
  Returns the count of unresponded chat users for a given user.

  ## Examples

      iex> get_count_unresponded_chat_users(user_id)
      [{1, 3}]

  """
  def get_count_unresponded_chat_users(user_id) do
    result =
      Repo.all(
        from cu in ChatUser,
          join: c in Chat,
          on: cu.chat_id == c.id,
          where:
            cu.was_read == false and (c.user_id_1 == ^user_id or c.user_id_2 == ^user_id) and
              cu.user_id != ^user_id,
          group_by: [cu.user_id],
          select: {cu.user_id, count()}
      )

    Enum.reduce(result, %{}, fn x, acc -> Map.put(acc, elem(x, 0), elem(x, 1)) end)
  end

  def update_chat_users(%ChatUser{} = chat_user, attrs) do
    chat_user
    |> ChatUser.changeset(attrs)
    |> Repo.update()
  end

  # TODO: Improve database update to send a batch of updates instead of one by one
  def update_unread_chat_users(chat_users) do
    chat_users
    |> Enum.filter(&(&1.was_read == false))
    |> Enum.map(&update_chat_users(&1, %{was_read: true}))
  end

  @doc """
  Gets a single chat.

  Raises `Ecto.NoResultsError` if the Chat does not exist.

  ## Examples

      iex> get_chat!(123)
      %Chat{}

      iex> get_chat!(456)
      ** (Ecto.NoResultsError)

  """
  def get_chat!(id), do: Repo.get!(Chat, id)

  @doc """
  Creates a chat.

  ## Examples

      iex> create_chat(%{field: value})
      {:ok, %Chat{}}

      iex> create_chat(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_chat(attrs \\ %{}) do
    %Chat{}
    |> Chat.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a chat.

  ## Examples

      iex> update_chat(chat, %{field: new_value})
      {:ok, %Chat{}}

      iex> update_chat(chat, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_chat(%Chat{} = chat, attrs) do
    chat
    |> Chat.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a chat.

  ## Examples

      iex> delete_chat(chat)
      {:ok, %Chat{}}

      iex> delete_chat(chat)
      {:error, %Ecto.Changeset{}}

  """
  def delete_chat(%Chat{} = chat) do
    Repo.delete(chat)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking chat changes.

  ## Examples

      iex> change_chat(chat)
      %Ecto.Changeset{data: %Chat{}}

  """
  def change_chat(%Chat{} = chat, attrs \\ %{}) do
    Chat.changeset(chat, attrs)
  end

  def create_chat_user(attrs \\ %{}) do
    %ChatUser{}
    |> ChatUser.changeset(attrs)
    |> Repo.insert()
  end
end
