defmodule Seeder do
  import Ecto.Query, warn: false

  alias BeExercise.Accounts
  alias BeExercise.Accounts.User
  alias BeExercise.Accounts.UserToken
  alias BeExercise.Finances
  alias BeExercise.Finances.Currency
  alias BeExercise.Finances.Salary
  alias BeExercise.Repo

  @names BEChallengex.list_names()
  @password "Password!123"

  def create_users(0, _), do: nil

  def create_users(seed_count) do
    1..seed_count
    |> Task.async_stream(
      fn n ->
        first_name = Enum.random(@names)
        second_name = Enum.random(@names)
        last_name = Enum.random(@names)
        name = "#{first_name} #{second_name} #{last_name}"
        email = format_email(first_name, last_name, n)
        attrs = %{name: name, email: email, password: @password}

        {:ok, user} = Accounts.register_user(attrs)
        confirm_user_token(user)
        create_salary(user)
      end,
      ordered: false,
      timeout: 3_600_000
    )
    |> Stream.run()
  end

  defp format_email(first, last, n) do
    first_name = String.replace(first, " ", "_")
    last_name = String.replace(last, " ", "_")
    String.downcase("#{first_name}.#{last_name}-#{n}@email.co")
  end

  defp confirm_user_token(%User{} = user) do
    {_, user_token} = UserToken.build_email_token(user, "confirm")
    Repo.insert!(user_token)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.confirm_changeset(user))
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, ["confirm"]))
    |> Repo.transaction()
  end

  defp create_salary(%User{} = user) do
    statuses = Enum.random([[:active, :inactive], [:inactive, :inactive]])
    currencies = Finances.get_random_currency(2)

    Enum.zip(currencies, statuses)
    |> Enum.each(fn {currency, status} ->
      year = Enum.random(2000..2022)
      month = Enum.random(1..12)
      day = Enum.random(1..27)
      hour = Enum.random(1..23)
      min_sec = Enum.random(0..59)
      inserted_at = NaiveDateTime.new!(year, month, day, hour, min_sec, min_sec)
      amount = Decimal.new(1, Enum.random(100..1_000_000), -2)

      Repo.insert!(%Salary{
        user_id: user.id,
        currency_id: currency.id,
        amount: amount,
        status: status,
        inserted_at: inserted_at,
        updated_at: inserted_at
      })
    end)
  end

  def create_currencies do
    if !Repo.exists?(Currency) do
      Repo.transaction(fn ->
        Repo.insert!(%Currency{code: "JPY", name: "Japanese Yen"})
        Repo.insert!(%Currency{code: "EUR", name: "Euro"})
        Repo.insert!(%Currency{code: "USD", name: "USA Dollar"})
        Repo.insert!(%Currency{code: "GBP", name: "Great Britain Pound"})
        Repo.insert!(%Currency{code: "INR", name: "Indian Rupee"})
      end)
    end
  end
end

seed_count = 10

Seeder.create_currencies()
Seeder.create_users(seed_count)
