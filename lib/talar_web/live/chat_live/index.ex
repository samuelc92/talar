defmodule TalarWeb.ChatLive.Index do
  use TalarWeb, :live_view

  alias Talar.Chats.ChatUser
  alias TalarWeb.UserAuth
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
      Accounts.subscribe(current_user.id)
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
    current_user = socket.assigns.current_user
    current_chat_id = socket.assigns.current_chat_id
    with {:ok, _chat_user} <- Chats.create_chat_user(%{user_id: current_user.id, chat_id: current_chat_id, message: chat_user["message"]}),
         chat_users <- Chats.get_chat_users_by_chat_id(current_chat_id),
         chat <- Chats.get_chat!(current_chat_id) do

      receiver_user_id = if chat.user_id_1 == current_user.id do
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
    chat = Chats.get_chat_by_user_preloaded(current_user.id, user.id)

    socket = socket
      |> assign(:current_chat_id, chat.id)
      |> assign(:open_chat_id, chat.id)

    {
      :noreply,
      stream(socket, :chats, chat.chat_users, reset: true)
    }
  end

  @impl true
  def handle_info(
      {Accounts, %Events.UserOnline{} = user_online},
      socket
    ) do
    IO.inspect("User #{user_online.username} is online at #{user_online.timestamp}")
    #TODO: Fetch user from database
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

  @impl true
  def handle_info(
      {Accounts, %Events.ReceivedMessage{} = message},
      socket
    ) do
    IO.inspect("Chat id #{message.chat_id} received at #{message.timestamp}")
    current_user = socket.assigns.current_user
    open_chat_id = socket.assigns.open_chat_id
    IO.inspect("I am #{current_user.username}")

    #TODO: Implement notification when user gets a message
    if open_chat_id == nil || open_chat_id != message.chat_id do
      {:noreply, socket}
    end

    chat_users = Chats.get_chat_users_by_chat_id(message.chat_id)
    {:noreply, stream(socket, :chats, chat_users)}
  end
end
