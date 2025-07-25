defmodule TalarWeb.ChatLiveTest do
  use TalarWeb.ConnCase

  import Phoenix.LiveViewTest
  import Talar.ChatsFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  defp create_chat(_) do
    chat = chat_fixture()
    %{chat: chat}
  end

  describe "Index" do
    setup [:create_chat]

    test "lists all chats", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/chats")

      assert html =~ "Listing Chats"
    end

    test "saves new chat", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/chats")

      assert index_live |> element("a", "New Chat") |> render_click() =~
               "New Chat"

      assert_patch(index_live, ~p"/chats/new")

      assert index_live
             |> form("#chat-form", chat: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#chat-form", chat: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/chats")

      html = render(index_live)
      assert html =~ "Chat created successfully"
    end

    test "updates chat in listing", %{conn: conn, chat: chat} do
      {:ok, index_live, _html} = live(conn, ~p"/chats")

      assert index_live |> element("#chats-#{chat.id} a", "Edit") |> render_click() =~
               "Edit Chat"

      assert_patch(index_live, ~p"/chats/#{chat}/edit")

      assert index_live
             |> form("#chat-form", chat: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#chat-form", chat: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/chats")

      html = render(index_live)
      assert html =~ "Chat updated successfully"
    end

    test "deletes chat in listing", %{conn: conn, chat: chat} do
      {:ok, index_live, _html} = live(conn, ~p"/chats")

      assert index_live |> element("#chats-#{chat.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#chats-#{chat.id}")
    end
  end

  describe "Show" do
    setup [:create_chat]

    test "displays chat", %{conn: conn, chat: chat} do
      {:ok, _show_live, html} = live(conn, ~p"/chats/#{chat}")

      assert html =~ "Show Chat"
    end

    test "updates chat within modal", %{conn: conn, chat: chat} do
      {:ok, show_live, _html} = live(conn, ~p"/chats/#{chat}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Chat"

      assert_patch(show_live, ~p"/chats/#{chat}/show/edit")

      assert show_live
             |> form("#chat-form", chat: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#chat-form", chat: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/chats/#{chat}")

      html = render(show_live)
      assert html =~ "Chat updated successfully"
    end
  end
end
