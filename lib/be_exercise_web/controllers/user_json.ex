defmodule BeExerciseWeb.UserJSON do
  alias BeExercise.Finances

  @doc """
  Renders a list of users.
  """
  def index(%{salaries: salaries}) do
    %{salaries: for(salary <- salaries, do: data(salary))}
  end

  @doc """
  Renders a paginated list of users.
  """
  def paginate_index(%{page: page}) do
    %{
      salaries: for(salary <- page.entries, do: data(salary)),
      next: page.metadata.after,
      prev: page.metadata.before,
      per_page: page.metadata.limit,
      total: page.metadata.total_count
    }
  end

  defp data(salary) do
    %{
      name: salary.name,
      salary: salary.amount,
      currency: Finances.get_currency_code(salary.currency_id),
      status: salary.status,
      updated_at: salary.updated_at
    }
  end
end
