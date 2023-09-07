defmodule BeExercise.Finances do
  @moduledoc false

  import Ecto.Query, warn: false
  alias BeExercise.Repo

  alias BeExercise.Accounts
  alias BeExercise.Finances.Currency
  alias BeExercise.Finances.Salary

  def list_users_salaries do
    Repo.all(Salary)
  end

  def send_email_invites do
    count =
      Salary
      |> join(:inner, [s], u in assoc(s, :user))
      |> where([s, _u], s.status == ^:active)
      |> select([_s, u], u)
      |> Repo.all()
      |> Task.async_stream(
        fn user ->
          {:ok, _} = BEChallengex.send_email(%{name: user.name})
        end,
        ordered: false,
        timeout: 3_600_000
      )
      |> Enum.to_list()
      |> length()

    {:ok, "sent #{count} emails"}
  end

  def list_recent_salaries(query) do
    Accounts.list_user_id(query)
    |> Enum.map(fn user ->
      get_recent_salary(user.id)
    end)
  end

  def get_recent_salary(user_id) do
    Salary
    |> preload([:user, :currency])
    |> where(user_id: ^user_id)
    |> order_by([
      fragment("case when status = 'active' then 1 else 2 end"),
      desc: :updated_at
    ])
    |> limit(1)
    |> Repo.one()
  end

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

  def create_currency(attrs) do
    %Currency{}
    |> Currency.changeset(attrs)
    |> Repo.insert!()
  end
end
