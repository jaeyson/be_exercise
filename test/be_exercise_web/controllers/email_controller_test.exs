defmodule BeExerciseWeb.EmailControllerTest do
  use BeExerciseWeb.ConnCase, async: true

  alias BeExercise.Seeder

  setup do
    Seeder.create_authorization_roles()
    Seeder.create_currencies()

    member_email = "john@smith.co"
    admin_email = "john@doe.co"
    password = "Password!123"

    Seeder.create_user(%{name: "John Smith", email: member_email, password: password})
    Seeder.create_user(%{name: "John Doe", email: admin_email, password: password}, "admin")

    %{member_email: member_email, admin_email: admin_email, password: password}
  end

  test "POST /invite-users", %{conn: conn, admin_email: email, password: password} do
    conn = post(conn, ~p"/login", %{email: email, password: password})
    %{"token" => token} = json_response(conn, :ok)

    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer #{token}")
      |> post(~p"/invite-users")

    assert %{"message" => _} = json_response(conn, :ok)
  end

  test "error: POST /invite-users with non-admin privilege", %{
    conn: conn,
    member_email: email,
    password: password
  } do
    conn = post(conn, ~p"/login", %{email: email, password: password})
    %{"token" => token} = json_response(conn, :ok)

    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer #{token}")
      |> post(~p"/invite-users")

    assert %{"error" => "Unauthorized"} = json_response(conn, :unauthorized)
  end

  test "error: POST /invite-users with invalid token" do
    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer 123")
      |> post(~p"/invite-users")

    assert %{"error" => "invalid_token"} = json_response(conn, :unauthorized)
  end

  test "error: POST /invite-users without bearer token", %{conn: conn} do
    conn = post(conn, ~p"/invite-users")
    assert %{"error" => "unauthenticated"} = json_response(conn, :unauthorized)
  end
end
