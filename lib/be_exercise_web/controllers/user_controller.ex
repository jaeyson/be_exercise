defmodule BeExerciseWeb.UserController do
  use BeExerciseWeb, :controller

  alias BeExercise.Finances

  action_fallback BeExerciseWeb.FallbackController

  def index(conn, params) do
    query = %{
      filter_by: params["filter_by"],
      order_by: params["order_by"]
    }

    users = Finances.list_recent_salaries(query)

    render(conn, :index, users: users)
  end

  def invite(conn, _params) do
    {:ok, message} = Finances.send_email_invites()
    render(conn, :invite_users, message: message)
  end
end
