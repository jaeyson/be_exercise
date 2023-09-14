defmodule BeExerciseWeb.Auth.Authorization do
  @moduledoc """
  Simple helper module for checking user privileges.
  """

  alias BeExerciseWeb.Auth.Guardian

  @doc """
  Checks if it can read all records. When a user
  is "member", it returns false.

  ## Examples

      iex> Authorization.can_read_all?(conn, 1)
      false

  """
  def can_read_all?(conn, user_id) do
    user = get_resource(conn)
    role = user.authorization_role.name

    cond do
      user.id === user_id && role === "member" -> false
      role !== "member" -> true
      true -> false
    end
  end

  @doc """
  Checks if it can read a record.

  ## Examples

      iex> Authorization.can_read?(conn, 1)
      true

  """
  def can_read?(conn, user_id) do
    user = get_resource(conn)
    role = user.authorization_role.name

    cond do
      user.id === user_id && role === "member" -> true
      role !== "member" -> true
      true -> false
    end
  end

  @doc """
  Gets the current resource from a conn. A resource
  is a User struct.

  ## Examples

      iex> Authorization.get_resource(conn)
      %BeExercise.Accounts.User{}

  """
  def get_resource(conn) do
    {:ok, resource, _claims} =
      conn
      |> Guardian.Plug.current_token()
      |> Guardian.resource_from_token()

    resource
  end
end
