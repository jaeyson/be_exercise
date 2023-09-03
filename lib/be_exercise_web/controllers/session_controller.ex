defmodule BeExerciseWeb.SessionController do
  use BeExerciseWeb, :controller
  alias BeExercise.Accounts

  def get_token(conn, %{"email" => email, "password" => password}) do
    user = Accounts.get_user_by_email_and_password(email, password)

    case user do
      nil ->
        conn |> put_status(401) |> json(%{error: "invalid credentials"})

      _ ->
        {:ok, jwt, _full_claims} =
          BeExerciseWeb.Guardian.encode_and_sign(user, %{}, ttl: {24, :hours})

        conn
        |> put_status(200)
        |> json(%{token: jwt})
    end
  end
end
