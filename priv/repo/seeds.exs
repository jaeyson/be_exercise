defmodule Seeder do
  import Ecto.Query, warn: false

  alias BeExercise.Accounts
  alias BeExercise.Accounts.User
  alias BeExercise.Accounts.UserToken
  alias BeExercise.Finances
  alias BeExercise.Finances.Currency
  alias BeExercise.Repo

  @names BEChallengex.list_names()
  @password "Password!123"

  def create_users(0, _), do: nil

  # Fixed seed count is the basis for total seed count since
  # we're using async stream to speed up the seeding
  # process. async_stream sometimes don't obey the seed count (20k)
  # in the readme instructions due to the nature of async,
  # hence why we're recursively calling it.
  def create_users(current_count, fixed_seed_count) do
    1..current_count
    |> Task.async_stream(
      fn _ ->
        first_name = Enum.random(@names)
        second_name = Enum.random(@names)
        last_name = Enum.random(@names)
        name = "#{first_name} #{second_name} #{last_name}"
        email = format_email(first_name, second_name, last_name)
        attrs = %{name: name, email: email, password: @password}

        {:ok, user} = Accounts.register_user(attrs)
        confirm_user_token(user)
        create_salary(user)
      end,
      ordered: false,
      timeout: 3_600_000
    )
    |> Stream.run()

    total_count_async = User |> select([u], count(u.id)) |> Repo.one()
    create_users(fixed_seed_count - current_count, fixed_seed_count)
  end

  defp format_email(first, second, last) do
    first_name = String.replace(first, " ", "_")
    second_name = String.replace(second, " ", "_")
    last_name = String.replace(last, " ", "_")
    String.downcase("#{first_name}.#{second_name}.#{last_name}@email.co")
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
    amount = Decimal.new(1, Enum.random(100..1_000_000), -2)
    statuses = Enum.random([[:active, :inactive], [:inactive, :inactive]])
    currencies = Finances.get_random_currency(2)

    Enum.zip(currencies, statuses)
    |> Enum.each(fn {currency, status} ->
      attrs = %{
        user_id: user.id,
        currency_id: currency.id,
        amount: amount,
        status: status
      }

      Finances.create_salary(attrs)
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

Seeder.create_currencies()
Seeder.create_users(10, 10)
