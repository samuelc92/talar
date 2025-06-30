defmodule TalarWeb.ChatLive.Index do
  use TalarWeb, :live_view

  #alias Talar.Chats
  #alias Talar.Chats.Chat

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
    #{:ok, stream(socket, :chats, [])}
    #{:ok, stream(socket, :chats, Chats.list_chats())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Chat")
    #|> assign(:chat, Chats.get_chat!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Chat")
    #|> assign(:chat, %Chat{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Chats")
    |> assign(:chat, nil)
  end

  @impl true
  def handle_info({TalarWeb.ChatLive.FormComponent, {:saved, chat}}, socket) do
    {:noreply, stream_insert(socket, :chats, chat)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    #chat = Chats.get_chat!(id)
    #{:ok, _} = Chats.delete_chat(chat)

    #{:noreply, stream_delete(socket, :chats, chat)}
    {:noreply, stream_delete(socket, :chats, nil)}
  end
end
