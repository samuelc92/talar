defmodule TalarWeb.Router do

  use TalarWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TalarWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TalarWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/login", LoginController, :index
    post "/login", LoginController, :create

    live "/chats", ChatLive.Index, :index
    live "/chats/new", ChatLive.Index, :new
    live "/chats/:id", ChatLive.Show, :show
#    live_session :default, on_mount: [{TalarWeb.UserAuth, :current_user}] do
#      live "/signin", SignInLive, :index
#    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", TalarWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:talar, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TalarWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
