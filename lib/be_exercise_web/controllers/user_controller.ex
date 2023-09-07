defmodule BeExerciseWeb.UserController do
  use BeExerciseWeb, :controller

  alias BeExercise.Finances

  action_fallback BeExerciseWeb.FallbackController

  def index(conn, params) do
    query = %{
      filter_by: params["filter_by"],
      order_by: params["order_by"]
    }

    salaries = Finances.list_recent_salaries(query)

    render(conn, :index, salaries: salaries)
  end

  def show(conn, %{"id" => id}) do
    check_salary = fn id ->
      case Finances.get_recent_salary(id) do
        nil ->
          {:error, :not_found}

        salary ->
          render(conn, :show, salary: salary)
      end
    end

    case Integer.parse(id) do
      {id, _} ->
        check_salary.(id)

      :error ->
        {:error, :not_found}
    end
  end

  def invite(conn, _params) do
    {:ok, message} = Finances.send_email_invites()
    render(conn, :invite_users, message: message)
  end
end
