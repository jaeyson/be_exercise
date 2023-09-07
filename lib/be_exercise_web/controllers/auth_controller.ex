defmodule BeExerciseWeb.AuthController do
  use BeExerciseWeb, :controller
  alias BeExercise.Accounts
  alias BeExerciseWeb.Auth.Guardian

  action_fallback BeExerciseWeb.FallbackController

  @ttl 2
  @unit_of_time :hours

  def register(conn, params) do
    with {:ok, user} <- Accounts.register_user(params),
         {:ok, _} <- Accounts.confirm_user_token(user) do
      {:ok, token, %{"exp" => expires}} =
        Guardian.encode_and_sign(user, %{}, ttl: {@ttl, @unit_of_time})

      conn
      |> put_status(:created)
      |> json(%{message: "successfully registered.", token: token, expires: expires})
    else
      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def login(conn, %{"email" => email, "password" => password}) do
    case Guardian.authenticate(email, password, @ttl, @unit_of_time) do
      {:ok, token, expires} ->
        put_token(conn, token, expires)

      {:error, :unauthorized} ->
        {:error, :unauthorized}
    end
  end

  def refresh_token(conn, %{}) do
    with old_token <- Guardian.Plug.current_token(conn),
         {:ok, claims} <- Guardian.decode_and_verify(old_token),
         {:ok, _user} <- Guardian.resource_from_claims(claims) do
      {:ok, _old, {new_token, %{"exp" => expires}}} =
        Guardian.refresh(old_token, ttl: {@ttl, @unit_of_time})

      put_token(conn, new_token, expires)
    else
      {:error, _reason} ->
        {:error, :not_found}
    end
  end

  def logout(conn, _params) do
    with token <- Guardian.Plug.current_token(conn),
         {:ok, _claims} <- Guardian.revoke(token) do
      conn
      |> put_status(:ok)
      |> json(%{message: "Successfully logged out."})
    end
  end

  defp put_token(conn, token, expires) do
    conn
    |> put_status(:ok)
    |> json(%{token: token, expires: expires})
  end
end
