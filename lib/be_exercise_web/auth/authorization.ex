defmodule BeExerciseWeb.Auth.Authorization do
  @moduledoc """
  Simple helper module for checking user privileges.
  """

  alias BeExerciseWeb.Auth.Guardian

  def can_read_all?(conn, user_id) do
    user = get_resource(conn)
    role = user.authorization_role.name

    cond do
      user.id === user_id && role === "member" -> false
      role !== "member" -> true
      true -> false
    end
  end

  def can_read?(conn, user_id) do
    user = get_resource(conn)
    role = user.authorization_role.name

    cond do
      user.id === user_id && role === "member" -> true
      role !== "member" -> true
      true -> false
    end
  end

  def get_resource(conn) do
    {:ok, resource, _claims} =
      conn
      |> Guardian.Plug.current_token()
      |> Guardian.resource_from_token()

    resource
  end
end
