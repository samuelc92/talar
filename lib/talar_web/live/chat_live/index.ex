defmodule TalarWeb.ChatLive.Index do
  alias Talar.Chats.ChatUser
  alias TalarWeb.UserAuth
  use TalarWeb, :live_view

  alias Phoenix.HTML.Format
  alias Talar.Accounts
  alias Talar.Accounts.{Events, User}
  alias Talar.Chats

  @impl true
  def mount(_params, session, socket) do
    current_user_session = session["current_user"]
    username = current_user_session["username"]
    current_user = Accounts.get_user_by_username(username)
    users_online = Accounts.list_online_users_but(current_user.email)
    form = to_form(ChatUser.changeset(%ChatUser{}, %{}))

    if connected?(socket) do
      Accounts.subscribe()
      Accounts.broadcast(%Events.UserOnline{username: username, timestamp: DateTime.utc_now()})
    end

    socket =
      socket
      |> assign(:users_online, users_online)
      |> assign(:current_user, current_user)
      |> assign(:form, form)

    {:ok, socket}
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
  def handle_event(
    "send_message",
    chat_user,
    socket
  ) do
    IO.inspect(chat_user)
    current_user = socket.assigns.current_user
    current_chat_id = socket.assigns.current_chat_id
    # TODO: WIP
    case Chats.create_chat_user(%{user_id: current_user.id, chat_id: current_chat_id, message: chat_user["message"]}) do
      {:ok, _chat_user} -> {:noreply, socket}
      {:error, _changeset} -> {:noreply, socket}
    end
    {:noreply, stream_insert(socket, :chats, %ChatUser{user_id: current_user.id, chat_id: current_chat_id, message: chat_user["message"], inserted_at: DateTime.utc_now()})}
  end

  @impl true
  def handle_event("open_chat", %{"username" => username}, socket) do
    user = Accounts.get_user_by_username(username)
    current_user = Accounts.get_user_by_username(socket.assigns.current_user.username)
    chat = Chats.get_chat_by_user_preloaded(current_user.id, user.id)

    {
      :noreply,
      stream(assign(socket, :current_chat_id, chat.id), :chats, chat.chat_users, reset: true)
    }
  end

  @impl true
  def handle_info(
      {Accounts, %Events.UserOnline{} = user_online},
      socket
    ) do
    IO.inspect("User #{user_online.username} is online at #{user_online.timestamp}")
    user = %User{username: user_online.username, email: "ttt"}

    if (user_online.username == socket.assigns.current_user.username || Enum.member?(socket.assigns.users_online, user)) do
      {:noreply, socket}
    else
      {
        :noreply,
        socket |> assign(:users_online, socket.assigns.users_online ++ [user])
      }
    end
  end
end
