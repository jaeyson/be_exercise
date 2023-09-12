defmodule BeExerciseWeb.UserController do
  use BeExerciseWeb, :controller

  alias BeExercise.Accounts
  alias BeExercise.Finances
  alias BeExerciseWeb.Auth.Authorization

  action_fallback BeExerciseWeb.FallbackController

  def index(conn, params) do
    query = %{
      filter_by: params["filter_by"],
      order_by: params["order_by"]
    }

    user = Authorization.get_resource(conn)

    salaries =
      if Authorization.can_read_all?(conn, user.id),
        do: Finances.list_recent_salaries(query),
        else: [Finances.get_recent_salary(user.id)]

    render(conn, :index, salaries: salaries)
  end

  def show(conn, %{"id" => id}) do
    user_id = Accounts.parse_user_id(id)

    render = fn id ->
      case Finances.get_recent_salary(id) do
        nil ->
          {:error, :not_found}

        salary ->
          render(conn, :show, salary: salary)
      end
    end

    if Authorization.can_read?(conn, user_id) do
      render.(user_id)
    else
      {:error, :unauthorized}
    end
  end
end
