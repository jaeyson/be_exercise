defmodule BeExerciseWeb.EmailController do
  use BeExerciseWeb, :controller

  alias BeExercise.Finances
  alias BeExerciseWeb.Auth.Authorization

  action_fallback BeExerciseWeb.FallbackController

  def invite(conn, _params) do
    user = Authorization.get_resource(conn)

    if user.authorization_role.name === "admin" do
      {:ok, message} = Finances.send_email_invites()
      render(conn, :invite_users, message: message)
    else
      {:error, :unauthorized}
    end
  end
end
