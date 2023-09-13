defmodule BeExerciseWeb.UserController do
  use BeExerciseWeb, :controller

  alias BeExercise.Finances
  alias BeExerciseWeb.Auth.Authorization

  action_fallback BeExerciseWeb.FallbackController

  def index(conn, params) do
    q = params["q"]
    order_by = BeExercise.set_default(params["order_by"], :desc)
    user = Authorization.get_resource(conn)

    salaries =
      if Authorization.can_read_all?(conn, user.id),
        do: Finances.list_salaries(%{q: q, order_by: order_by}),
        else: Finances.list_own_salary(%{user_id: user.id})

    render(conn, :index, salaries: salaries)
  end

  def paginate_index(conn, params) do
    prev = BeExercise.set_default(params["before"])
    next = BeExercise.set_default(params["after"])
    order_by = BeExercise.set_default(params["order_by"], :desc)
    per_page = params["per_page"]
    q = params["q"]

    query = %{
      before: prev,
      after: next,
      q: q,
      order_by: order_by,
      per_page: per_page
    }

    user = Authorization.get_resource(conn)

    page =
      if Authorization.can_read_all?(conn, user.id),
        do: Finances.paginate_salaries(query),
        else: Finances.paginate_own_salary(%{user_id: user.id})

    render(conn, :paginate_index, page: page)
  end
end
