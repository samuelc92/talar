defmodule TalarWeb.PageController do
  use TalarWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    user = get_session(conn, :current_user)
    IO.inspect(user)
    render(conn, :home, layout: false)
  end
end
