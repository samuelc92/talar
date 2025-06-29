defmodule Talar.Repo do
  use Ecto.Repo,
    otp_app: :talar,
    adapter: Ecto.Adapters.Postgres
end
