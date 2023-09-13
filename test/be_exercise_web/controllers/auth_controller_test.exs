defmodule BeExerciseWeb.AuthControllerTest do
  use BeExerciseWeb.ConnCase, async: true

  alias BeExercise.Seeder

  setup do
    Seeder.create_authorization_roles()
    Seeder.create_currencies()

    name = "John Smith"
    email = "john@test.co"
    password = "Password!123"
    Seeder.create_user(%{name: name, email: email, password: password})

    register_body =
      %{
        name: "test user",
        email: "test@test.co",
        password: "Password!123"
      }

    %{email: email, password: password, body: register_body}
  end

  test "POST /register", %{conn: conn, body: body} do
    conn = post(conn, ~p"/register", body)
    assert %{"message" => _, "token" => _, "expires" => _} = json_response(conn, :created)
  end

  test "error: POST /register with missing name field", %{conn: conn, body: body} do
    body = Map.drop(body, [:name])
    conn = post(conn, ~p"/register", body)

    assert %{"errors" => %{"name" => ["can't be blank"]}} =
             json_response(conn, :unprocessable_entity)
  end

  test "error: POST /register with missing email field", %{conn: conn, body: body} do
    body = Map.drop(body, [:email])
    conn = post(conn, ~p"/register", body)

    assert %{"errors" => %{"email" => ["can't be blank"]}} =
             json_response(conn, :unprocessable_entity)
  end

  test "error: POST /register with missing password field", %{conn: conn, body: body} do
    body = Map.drop(body, [:password])
    conn = post(conn, ~p"/register", body)

    assert %{"errors" => %{"password" => ["can't be blank"]}} =
             json_response(conn, :unprocessable_entity)
  end

  test "POST /login", %{conn: conn, email: email, password: password} do
    body = %{email: email, password: password}

    conn = post(conn, ~p"/login", body)
    assert %{"token" => _, "expires" => _} = json_response(conn, :ok)
  end

  test "error: POST /login", %{conn: conn} do
    body = %{
      email: "unknown@example.com",
      password: "Password!123"
    }

    conn = post(conn, ~p"/login", body)
    assert json_response(conn, :unauthorized)
  end

  test "GET /refresh-token", %{conn: conn, email: email, password: password} do
    conn = post(conn, ~p"/login", %{email: email, password: password})
    %{"token" => token} = json_response(conn, :ok)

    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer #{token}")
      |> get(~p"/refresh-token")

    %{"token" => new_token, "expires" => _} = json_response(conn, :ok)
    assert token !== new_token
  end

  test "error: GET /refresh-token with invalid token" do
    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer 123")
      |> get(~p"/refresh-token")

    assert %{"error" => "invalid_token"} = json_response(conn, :unauthorized)
  end

  test "error: GET /refresh-token without bearer token", %{conn: conn} do
    conn = get(conn, ~p"/refresh-token")
    assert %{"error" => "unauthenticated"} = json_response(conn, :unauthorized)
  end

  test "DELETE /logout", %{conn: conn, email: email, password: password} do
    conn = post(conn, ~p"/login", %{email: email, password: password})
    %{"token" => token} = json_response(conn, :ok)

    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer #{token}")
      |> delete(~p"/logout")

    assert %{"message" => "Successfully logged out."} = json_response(conn, :ok)
  end

  test "error: DELETE /logout with invalid token" do
    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer 123")
      |> delete(~p"/logout")

    assert %{"error" => "invalid_token"} = json_response(conn, :unauthorized)
  end

  test "error: DELETE /logout without bearer token", %{conn: conn} do
    conn = delete(conn, ~p"/logout")
    assert %{"error" => "unauthenticated"} = json_response(conn, :unauthorized)
  end
end
