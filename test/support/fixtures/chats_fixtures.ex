defmodule Talar.ChatsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Talar.Chats` context.
  """

  @doc """
  Generate a chat.
  """
  def chat_fixture(attrs \\ %{}) do
    {:ok, chat} =
      attrs
      |> Enum.into(%{})
      |> Talar.Chats.create_chat()

    chat
  end
end
