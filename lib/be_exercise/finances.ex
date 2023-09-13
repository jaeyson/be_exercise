defmodule BeExercise.Finances do
  @moduledoc """
  Module for listing salaries.
  """

  import Ecto.Query, warn: false
  alias BeExercise.Repo

  alias BeExercise.Accounts.User
  alias BeExercise.Finances.Currency
  alias BeExercise.Finances.Salary

  @per_page 12

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

    {:ok, "sent #{count} email(s)"}
  end

  def list_own_salary(%{user_id: user_id}) do
    salaries_query(%{order_by: :desc})
    |> where([u, _, _], u.id == ^user_id)
    |> Repo.all()
  end

  def list_salaries(%{q: q, order_by: order_by}) do
    salaries_query(%{order_by: order_by})
    |> where([u, _, _], ilike(u.name, ^"%#{q}%"))
    |> Repo.all()
  end

  def paginate_own_salary(%{user_id: user_id}) do
    salaries_query(%{order_by: :desc})
    |> where([u, _, _], u.id == ^user_id)
    |> Repo.paginate(
      before: nil,
      after: nil,
      include_total_count: true,
      cursor_fields: [:inserted_at, :id],
      limit: 1
    )
  end

  def paginate_salaries(%{
        q: q,
        order_by: order_by,
        before: prev_page,
        after: next_page,
        per_page: per_page
      }) do
    limit = BeExercise.set_int(per_page, @per_page)

    salaries_query(%{order_by: order_by})
    |> where([u, _, _], ilike(u.name, ^"%#{q}%"))
    |> Repo.paginate(
      before: prev_page,
      after: next_page,
      include_total_count: true,
      cursor_fields: [:inserted_at, :id],
      limit: limit
    )
  end

  def get_currency_code(currency_id) when is_integer(currency_id) do
    Currency
    |> where(id: ^currency_id)
    |> select([c], c.code)
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
    |> Repo.insert()
  end

  def create_currency(attrs) do
    %Currency{}
    |> Currency.changeset(attrs)
    |> Repo.insert()
  end

  defp salaries_query(%{order_by: order_by}) do
    User
    |> join(
      :left,
      [u],
      s_active in subquery(
        from s in Salary,
          select: %{
            user_id: s.user_id,
            amount: s.amount,
            currency_id: s.currency_id,
            status: s.status,
            updated_at: s.updated_at
          },
          where: s.status == :active
      ),
      on: u.id == s_active.user_id
    )
    |> join(
      :left,
      [u, _s_active],
      s_inactive in subquery(
        from(
          si in subquery(
            from(s in Salary,
              where: s.status == :inactive,
              select: %{
                user_id: s.user_id,
                amount: s.amount,
                currency_id: s.currency_id,
                status: s.status,
                updated_at: s.updated_at,
                rn: fragment("ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY updated_at DESC)")
              }
            )
          ),
          select: %{
            user_id: si.user_id,
            amount: si.amount,
            currency_id: si.currency_id,
            status: si.status,
            updated_at: si.updated_at
          },
          where: si.rn == 1
        )
      ),
      on: u.id == s_inactive.user_id
    )
    |> select([u, s_active, s_inactive], %{
      name: u.name,
      amount: coalesce(s_active.amount, s_inactive.amount),
      currency_id: coalesce(s_active.currency_id, s_inactive.currency_id),
      status: coalesce(s_active.status, s_inactive.status),
      updated_at: coalesce(s_active.updated_at, s_inactive.updated_at)
    })
    |> order_by(^{order_by, :name})
  end
end
