defmodule Talar.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Talar.Accounts` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{email: "some email", username: "some username"}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{})
      |> Talar.Accounts.create_user()

    user
  end
end
