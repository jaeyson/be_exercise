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

  pipeline :api_auth do
    plug BeExerciseWeb.Pipeline
  end

  pipeline :ensure_api_auth do
    plug Guardian.Plug.EnsureAuthenticated
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BeExerciseWeb do
    pipe_through :api

    get "/", PageController, :ping
    get "/get-token", SessionController, :get_token
  end

  scope "/", BeExerciseWeb do
    pipe_through [:api, :api_auth, :ensure_api_auth]

    get "/users/:id", UserController, :show
    get "/users", UserController, :index
    post "/invite-users", UserController, :invite
  end

  if Application.compile_env(:be_exercise, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: BeExerciseWeb.Telemetry
    end
  end
end
