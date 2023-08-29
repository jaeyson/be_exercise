defmodule BeExerciseWeb.UserJSON do
  alias BeExercise.Finances.Salary

  @doc """
  Renders a list of users.
  """
  def index(%{users: users}) do
    %{data: for(user <- users, do: data(user))}
  end

  @doc """
  Sends an email to all users and returns a count of sent emails.
  """
  def invite_users(%{message: message}) do
    %{message: message}
  end

  @doc """
  Renders a single user.
  """
  def show(%{user: user}) do
    %{data: data(user)}
  end

  defp data(%Salary{} = salary) do
    name = salary.user.name
    amount = salary.amount
    currency = salary.currency.code
    status = salary.status
    updated_at = salary.updated_at

    %{
      name: name,
      salary: amount,
      currency: currency,
      status: status,
      updated_at: updated_at
    }
  end
end
