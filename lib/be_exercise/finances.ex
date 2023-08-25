defmodule BeExercise.Finances do
  @moduledoc false

  import Ecto.Query, warn: false
  alias BeExercise.Repo

  alias BeExercise.Finances.Currency
  alias BeExercise.Finances.Salary

  def get_random_currency(count) do
    Currency
    |> limit(^count)
    |> order_by(fragment("RANDOM()"))
    |> Repo.all()
  end

  def create_salary(attrs) do
    %Salary{}
    |> Salary.changeset(attrs)
    |> Repo.insert!()
  end
end
