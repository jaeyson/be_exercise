defmodule BeExercise.Seeder do
  @moduledoc """
  Module helper for seeding data.
  """

  require Logger
  alias BeExercise.Accounts
  alias BeExercise.Accounts.AuthorizationRole
  alias BeExercise.Finances
  alias BeExercise.Finances.Currency
  alias BeExercise.Repo

  @names BEChallengex.list_names()
  @password "Password!123"

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
        authorization_role_id = Accounts.get_authorization_role_id(role)

        attrs =
          %{
            name: name,
            email: email,
            password: @password,
            authorization_role_id: authorization_role_id
          }

        {:ok, user} = Accounts.register_user(attrs)
        {:ok, _} = Accounts.confirm_user_token(user)
        create_salary(user)
        Logger.info("entry #{n}")
      end,
      ordered: false,
      timeout: 3_600_000
    )
    |> Stream.run()
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
end
