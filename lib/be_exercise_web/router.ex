defmodule BeExerciseWeb.Router do
  use BeExerciseWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {BeExerciseWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :auth do
    plug BeExerciseWeb.Auth.Pipeline
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BeExerciseWeb do
    pipe_through :api

    get "/", PageController, :ping
    post "/register", AuthController, :register
    post "/login", AuthController, :login
  end

  scope "/", BeExerciseWeb do
    pipe_through [:api, :auth]

    get "/users", UserController, :index
    get "/paginate-users", UserController, :paginate_index
    post "/invite-users", EmailController, :invite
    get "/refresh-token", AuthController, :refresh_token
    delete "/logout", AuthController, :delete
  end

  if Application.compile_env(:be_exercise, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: BeExerciseWeb.Telemetry
    end
  end
end
