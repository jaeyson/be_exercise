defmodule BeExerciseWeb.UserControllerTest do
  use BeExerciseWeb.ConnCase, async: true

  alias BeExercise.Seeder

  setup do
    Seeder.create_authorization_roles()
    Seeder.create_currencies()
    Seeder.create_users(5)

    member_email = "john@smith.co"
    admin_email = "john@doe.co"
    password = "Password!123"

    Seeder.create_user(%{name: "John Smith", email: member_email, password: password})
    Seeder.create_user(%{name: "John Doe", email: admin_email, password: password}, "admin")

    %{member_email: member_email, admin_email: admin_email, password: password}
  end

  test "GET /users shows all when non-member", %{
    conn: conn,
    admin_email: email,
    password: password
  } do
    conn = post(conn, ~p"/login", %{email: email, password: password})
    %{"token" => token} = json_response(conn, :ok)

    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer #{token}")
      |> get(~p"/users")

    %{"salaries" => data} = json_response(conn, :ok)
    assert length(data) === 7
  end

  test "GET /users only shows own record when member", %{
    conn: conn,
    member_email: email,
    password: password
  } do
    conn = post(conn, ~p"/login", %{email: email, password: password})
    %{"token" => token} = json_response(conn, :ok)

    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer #{token}")
      |> get(~p"/users")

    assert %{
             "salaries" => [
               %{
                 "currency" => _currency,
                 "name" => _name,
                 "salary" => _salary,
                 "status" => _status,
                 "updated_at" => _updated_at
               }
             ]
           } = json_response(conn, :ok)
  end

  test "GET /paginate-users shows all when non-member", %{
    conn: conn,
    admin_email: email,
    password: password
  } do
    conn = post(conn, ~p"/login", %{email: email, password: password})
    %{"token" => token} = json_response(conn, :ok)

    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer #{token}")
      |> get(~p"/paginate-users")

    assert %{
             "total" => 7,
             "next" => nil,
             "prev" => nil,
             "per_page" => 12,
             "salaries" => _salaries
           } = json_response(conn, :ok)
  end

  test "GET /paginate-users only shows own record when member", %{
    conn: conn,
    member_email: email,
    password: password
  } do
    conn = post(conn, ~p"/login", %{email: email, password: password})
    %{"token" => token} = json_response(conn, :ok)

    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer #{token}")
      |> get(~p"/paginate-users")

    assert %{
             "total" => 1,
             "next" => nil,
             "prev" => nil,
             "per_page" => 1,
             "salaries" => [
               %{
                 "currency" => _currency,
                 "name" => _name,
                 "salary" => _salary,
                 "status" => _status,
                 "updated_at" => _updated_at
               }
             ]
           } = json_response(conn, :ok)
  end

  test "error: GET /users with invalid token" do
    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer 123")
      |> get(~p"/users")

    assert %{"error" => "invalid_token"} = json_response(conn, :unauthorized)
  end

  test "error: GET /users without bearer token", %{conn: conn} do
    conn = get(conn, ~p"/users")
    assert %{"error" => "unauthenticated"} = json_response(conn, :unauthorized)
  end
end
