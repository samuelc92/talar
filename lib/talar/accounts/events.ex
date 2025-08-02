defmodule Talar.Accounts.Events do
  defmodule UserOnline do
    defstruct [:username, :timestamp]
  end

  defmodule ReceivedMessage do
    defstruct [:chat_id, :timestamp]
  end
end
