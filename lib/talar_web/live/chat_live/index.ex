defmodule TalarWeb.ChatLive.Index do
  alias TalarWeb.UserAuth
  use TalarWeb, :live_view

  alias Talar.Accounts
  alias Talar.Accounts.Events
  alias Talar.Accounts.User
  #alias Talar.Chats
  #alias Talar.Chats.Chat

  @impl true
  def mount(_params, session, socket) do
    current_user = session["current_user"]
    username = current_user["username"]
    users_online = Accounts.list_online_users_but(current_user["email"]) #[%User{username: current_user["username"], email: current_user["email"]}]

    if connected?(socket) do
      Accounts.subscribe()
      Accounts.broadcast(%Events.UserOnline{username: username, timestamp: DateTime.utc_now()})
    end

    socket =
      socket
      #|> stream(:users_online, users_online)
      |> assign(:users_online, users_online)
      |> assign(:current_user, session["current_user"])

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

  #@impl true
  #def handle_info({TalarWeb.ChatLive.FormComponent, {:saved, chat}}, socket) do
  #  {:noreply, stream_insert(socket, :chats, chat)}
  #end

  @impl true
  #def handle_event("delete", %{"id" => id}, socket) do
  def handle_event("open_chat", %{"username" => username}, socket) do
    #{:ok, _} = Chats.delete_chat(chat)
    IO.inspect("User #{username} deleted")
    {:noreply, socket}
  end

  @impl true
  def handle_info(
      {Accounts, %Events.UserOnline{} = user_online},
      socket
    ) do
    IO.inspect("User #{user_online.username} is online at #{user_online.timestamp}")
    user = %User{username: user_online.username, email: "ttt"}

    if (user_online.username == socket.assigns.current_user["username"] || Enum.member?(socket.assigns.users_online, user)) do
      {:noreply, socket}
    else
      {
        :noreply,
        socket |> assign(:users_online, socket.assigns.users_online ++ [user])
      }
    end
  end
end
