defmodule BeExercise.Seeder do
  @moduledoc """
  Module helper for seeding data.
  """

  require Logger
  alias BeExercise.Accounts
  alias BeExercise.Accounts.User
  alias BeExercise.Accounts.AuthorizationRole
  alias BeExercise.Finances
  alias BeExercise.Finances.Currency
  alias BeExercise.Finances.Salary
  alias BeExercise.Repo

  @names BEChallengex.list_names()
  @password "Password!123"

  def create_users_v2(seed_count) do
    users =
      1..seed_count
      |> Enum.map(fn n ->
        first_name = Enum.random(@names)
        second_name = Enum.random(@names)
        last_name = Enum.random(@names)
        name = "#{first_name} #{second_name} #{last_name}"
        email = format_email(first_name, last_name, System.unique_integer())
        inserted_at = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
        Logger.info("seed #{n}")

        %{
          name: name,
          email: email,
          hashed_password: @password,
          authorization_role_id: 1,
          inserted_at: inserted_at,
          updated_at: inserted_at
        }
      end)

    {_count, users} = Repo.insert_all(User, users, returning: [:id])
    statuses = Enum.random([[:active, :inactive], [:inactive, :inactive]])
    currencies = Finances.get_random_currencies(2)

    salaries =
      Enum.map(users, fn user ->
        Enum.zip(currencies, statuses)
        |> Enum.map(fn {currency, status} ->
          inserted_at =
            NaiveDateTime.new!(
              Enum.random(2000..2022),
              Enum.random(1..12),
              Enum.random(1..27),
              Enum.random(1..23),
              Enum.random(0..59),
              Enum.random(0..59)
            )

          updated_at = NaiveDateTime.add(inserted_at, Enum.random(1..27), :day)

          %{
            user_id: user.id,
            status: status,
            amount: Decimal.new(1, Enum.random(100..1_000_000), -2),
            currency_id: currency.id,
            inserted_at: inserted_at,
            updated_at: updated_at
          }
        end)
      end)
      |> List.flatten()

    Repo.insert_all(Salary, salaries)
  end

  def create_users(seed_count, role \\ "member")
  def create_users(0, _), do: nil

  def create_users(seed_count, role) do
    1..seed_count
    |> Task.async_stream(
      fn n ->
        first_name = Enum.random(@names)
        second_name = Enum.random(@names)
        last_name = Enum.random(@names)
        name = "#{first_name} #{second_name} #{last_name}"
        email = format_email(first_name, last_name, System.unique_integer())
        attrs = %{name: name, email: email, password: @password}

        create_user(attrs, role)
        Logger.info("entry #{n}")
      end,
      ordered: false,
      timeout: 3_600_000
    )
    |> Stream.run()
  end

  def create_user(attrs, role \\ "member") do
    role_id = Accounts.get_authorization_role_id(role)
    attrs = Map.put(attrs, :authorization_role_id, role_id)

    {:ok, user} = Accounts.register_user(attrs)
    {:ok, _} = Accounts.confirm_user_token(user)
    create_salary(user)
  end

  def create_currencies do
    if !Repo.exists?(Currency) do
      Repo.transaction(fn ->
        Finances.create_currency(%{code: "JPY", name: "Japanese Yen"})
        Finances.create_currency(%{code: "EUR", name: "Euro"})
        Finances.create_currency(%{code: "USD", name: "USA Dollar"})
        Finances.create_currency(%{code: "GBP", name: "Great Britain Pound"})
        Finances.create_currency(%{code: "INR", name: "Indian Rupee"})
      end)
    end
  end

  def create_authorization_roles do
    if !Repo.exists?(AuthorizationRole) do
      ~w(member finance admin)
      |> Enum.each(&Repo.insert!(%AuthorizationRole{name: &1}))
    end
  end

  defp format_email(first, last, n) do
    first_name = String.replace(first, " ", "_")
    last_name = String.replace(last, " ", "_")
    String.downcase("#{first_name}.#{last_name}#{n}@email.co")
  end

  defp create_salary(user) do
    statuses = Enum.random([[:active, :inactive], [:inactive, :inactive]])
    currencies = Finances.get_random_currencies(2)

    entries =
      Enum.zip(currencies, statuses)
      |> Enum.map(fn {currency, status} ->
        inserted_at =
          NaiveDateTime.new!(
            Enum.random(2000..2022),
            Enum.random(1..12),
            Enum.random(1..27),
            Enum.random(1..23),
            Enum.random(0..59),
            Enum.random(0..59)
          )

        updated_at = NaiveDateTime.add(inserted_at, Enum.random(1..27), :day)

        %{
          user_id: user.id,
          status: status,
          amount: Decimal.new(1, Enum.random(100..1_000_000), -2),
          currency_id: currency.id,
          inserted_at: inserted_at,
          updated_at: updated_at
        }
      end)

    Repo.insert_all(Salary, entries)
  end
end
