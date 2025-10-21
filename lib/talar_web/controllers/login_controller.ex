defmodule TalarWeb.LoginController do
  use TalarWeb, :controller

  alias Talar.Accounts.User
  alias Talar.Accounts

  def index(conn, _params) do
    changeset = User.changeset(%User{}, %{})

    conn
    |> render(:index, layout: false, changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.changeset(%User{}, user_params)

    if changeset.valid? do
      # Here you would typically authenticate the user
      # For now, we'll just redirect to a success page
      case Accounts.create_or_update_user(user_params) do
        {:ok, _user} ->
          conn
          |> put_flash(:info, "Login successful!")
          |> put_user_in_session(user_params)
          |> redirect(to: ~p"/chats")

        {:error, error} ->
          IO.inspect(error, label: "Login Error")

          conn
          |> put_flash(:error, "Login failed!")
          |> redirect(to: ~p"/login")
      end
    else
      conn
      |> render(:index, layout: false, changeset: changeset)
    end
  end

  # Store user information in session
  def put_user_in_session(conn, user_params) do
    conn
    |> put_session(:current_user, user_params)
    |> assign(:current_user, user_params)
  end

  # Get user information from session
  def get_user_from_session(conn) do
    get_session(conn, :current_user)
  end
end
