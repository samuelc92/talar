defmodule Talar.Accounts do
  import Ecto.Query, warn: false

  alias Talar.Repo
  alias Talar.Accounts.User

  @pubsub Talar.PubSub

  def subscribe do
    Phoenix.PubSub.subscribe(@pubsub, "users")
  end

  def unsubscribe do
    Phoenix.PubSub.unsubscribe(@pubsub, "users")
  end

  def broadcast(msg) do
    Phoenix.PubSub.local_broadcast(@pubsub, "users", {__MODULE__, msg})
  end

  def list_users do
    Repo.all(User)
  end

  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end

  def create_or_update_user(user_params) do
    user = get_user_by_email(user_params["email"])
    if user == nil do
      create_user(user_params)
    else
      update_user(user, %{status: :online})
    end
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end
end
