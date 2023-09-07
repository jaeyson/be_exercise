defmodule Seeder do
  import Ecto.Query, warn: false

  alias BeExercise.Accounts
  alias BeExercise.Finances
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
        {:ok, _} = Accounts.confirm_user_token(user, :seeder)
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

  defp create_salary(user) do
    statuses = Enum.random([[:active, :inactive], [:inactive, :inactive]])
    currencies = Finances.get_random_currency(2)

    Enum.zip(currencies, statuses)
    |> Enum.each(fn {currency, status} ->
      inserted_at =
        NaiveDateTime.new!(
          Enum.random(2000..2022),
          Enum.random(1..12),
          Enum.random(1..27),
          Enum.random(1..23),
          Enum.random(0..59),
          Enum.random(0..59)
        )

      attrs = %{
        user_id: user.id,
        status: status,
        amount: Decimal.new(1, Enum.random(100..1_000_000), -2),
        currency_id: currency.id,
        inserted_at: inserted_at,
        updated_at: inserted_at
      }

      Finances.create_salary(attrs)
    end)
  end

  def create_currencies do
    Repo.transaction(fn ->
      [
        {"JPY", "Japanese Yen"},
        {"EUR", "Euro"},
        {"USD", "USA Dollar"},
        {"GBP", "Great Britain Pound"},
        {"INR", "Indian Rupee"}
      ]
      |> Enum.each(fn {code, name} -> Finances.create_currency(%{code: code, name: name}) end)
    end)
  end
end

seed_count = 10

Seeder.create_currencies()
Seeder.create_users(seed_count)
