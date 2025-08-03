defmodule Talar.Accounts.Events do
  defmodule UserOnline do
    alias Talar.Accounts.User
    defstruct user: %User{}, timestamp: DateTime.utc_now()
  end

  defmodule ReceivedMessage do
    defstruct [:chat_id, :timestamp]
  end
end
