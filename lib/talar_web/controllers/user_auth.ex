defmodule TalarWeb.UserAuth do
  def on_mount(:current_user, _params, _session, socket) do
    {:cont, Phoenix.Component.assign(socket, :current_user, nil)}
  end
end
