defmodule TalarWeb.ChatLive.Index do
  use TalarWeb, :live_view

  alias Talar.Chats.ChatUser
  alias Talar.Accounts
  alias Talar.Accounts.{Events}
  alias Talar.Chats

  @impl true
  def mount(_params, session, socket) do
    current_user_session = session["current_user"]
    username = current_user_session["username"]
    current_user = Accounts.get_user_by_username(username)
    users_online = Accounts.list_online_users_but(current_user.email)
    form = to_form(ChatUser.changeset(%ChatUser{}, %{}))

    if connected?(socket) do
      Accounts.subscribe(current_user.id)
      Accounts.subscribe()
      Accounts.broadcast(%Events.UserOnline{user: current_user, timestamp: DateTime.utc_now()})
    end

    socket =
      socket
      |> assign(:users_online, users_online)
      |> assign(:current_user, current_user)
      |> assign(:form, form)
      |> assign(:unread_messages, Chats.get_count_unresponded_chat_users(current_user.id))

    {:ok, socket}
  end

  @impl true
  def handle_event(
    "send_message",
    chat_user,
    socket
  ) do
    current_user = socket.assigns.current_user
    current_chat_id = socket.assigns.current_chat_id
    with {:ok, _chat_user} <- Chats.create_chat_user(%{user_id: current_user.id, chat_id: current_chat_id, message: chat_user["message"]}),
         chat_users <- Chats.get_chat_users_by_chat_id(current_chat_id),
         chat <- Chats.get_chat!(current_chat_id) do
      receiver_user_id =
        if chat.user_id_1 == current_user.id do
          chat.user_id_2
        else
          chat.user_id_1
        end

      Accounts.broadcast(%Events.ReceivedMessage{chat_id: current_chat_id, timestamp: DateTime.utc_now()}, receiver_user_id)
      #TODO: There is a bug when the user sends the first messsage it works.
      # However from the second message the text field is not cleared.
      form = to_form(ChatUser.changeset(%ChatUser{}, %{message: ""}))
      {:noreply, stream(assign(socket, form: form), :chats, chat_users)}
    else
      {:error, _} -> {:noreply, socket}
    end
  end

  @impl true
  def handle_event("open_chat", %{"username" => username}, socket) do
    user = Accounts.get_user_by_username(username)
    current_user = Accounts.get_user_by_username(socket.assigns.current_user.username)

    {:ok, chat} = case Chats.get_chat_by_user_preloaded(current_user.id, user.id) do
      nil -> Chats.create_chat(%{user_id_1: current_user.id, user_id_2: user.id})
      chat -> {:ok, chat}
    end

    chat = if Ecto.assoc_loaded?(chat.chat_users) do
      Chats.update_unread_chat_users(chat.chat_users)
      chat
    else
      Chats.get_chat_preloaded!(chat.id)
    end

    socket = socket
      |> assign(:current_chat_id, chat.id)
      |> assign(:open_chat_id, chat.id)
      |> assign(:chat_with_username, username)
      |> assign(:unread_messages, Chats.get_count_unresponded_chat_users(current_user.id))

    {
      :noreply,
      stream(
        socket,
        :chats,
        if chat.chat_users == nil do [] else chat.chat_users end,
        reset: true)
    }
  end

  @impl true
  def handle_info(
      {Accounts, %Events.ReceivedMessage{} = message},
      socket
    ) do
    IO.inspect("Chat id #{message.chat_id} received at #{message.timestamp}")
    current_user = socket.assigns.current_user
    open_chat_id = socket.assigns.open_chat_id
    IO.inspect("I am #{current_user.username}")

    if open_chat_id == nil || open_chat_id != message.chat_id do
      {:noreply, socket |> assign(:unread_messages, Chats.get_count_unresponded_chat_users(current_user.id))}
    end

    chat_users = Chats.get_chat_users_by_chat_id(message.chat_id)
    Chats.update_unread_chat_users(chat_users)

    {:noreply, stream(socket, :chats, chat_users)}
  end

  @impl true
  def handle_info(
      {Accounts, %Events.UserOnline{} = user_online},
      socket
    ) do
    IO.inspect(user_online)
    if is_current_user?(user_online.user, socket) || is_user_duplicated?(user_online.user, socket) do
      {:noreply, socket}
    else
      {
        :noreply,
        socket |> assign(:users_online, socket.assigns.users_online ++ [user_online.user])
      }
    end
  end

  defp is_current_user?(user, socket) do
    user.username == socket.assigns.current_user.username
  end

  defp is_user_duplicated?(user, socket) do
    Enum.member?(socket.assigns.users_online, user)
  end
end
