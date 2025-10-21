defmodule Talar.ChatsTest do
  use Talar.DataCase

  alias Talar.Chats
  alias Talar.Accounts

  describe "chats" do
    import Talar.ChatsFixtures

    @invalid_attrs %{}

    test "list_chats/0 returns all chats" do
      user_1_attrs = %{username: "user1", email: "user1@example.com"}
      user_2_attrs = %{username: "user2", email: "user2@example.com"}
      {:ok, user_1} = Accounts.create_user(user_1_attrs)
      {:ok, user_2} = Accounts.create_user(user_2_attrs)

      valid_attrs = %{user_id_1: user_1.id, user_id_2: user_2.id}
      chat = chat_fixture(valid_attrs)
      assert Chats.list_chats() == [chat]
    end

    test "create_chat/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chats.create_chat(@invalid_attrs)
    end

    # test "update_chat/2 with invalid data returns error changeset" do
    # valid_attrs = %{user_id_1: user_1.id, user_id_2: user_2.id}
    # chat = chat_fixture(valid_attrs)
    # assert {:error, %Ecto.Changeset{}} = Chats.update_chat(chat, @invalid_attrs)
    # assert chat == Chats.get_chat!(chat.id)
    # end

    # test "delete_chat/1 deletes the chat" do
    # chat = chat_fixture(%{user_id_1: 1, user_id_2: 2})
    # chat = chat_fixture()
    # assert {:ok, %Chat{}} = Chats.delete_chat(chat)
    # assert_raise Ecto.NoResultsError, fn -> Chats.get_chat!(chat.id) end
    # end
  end
end
