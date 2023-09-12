defmodule BeExercise.Finances.Salary do
  @moduledoc """
  Salary schema and changesets
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias BeExercise.Accounts.User
  alias BeExercise.Finances.Currency

  @primary_key false
  schema "salaries" do
    belongs_to :user, User
    belongs_to :currency, Currency
    field :amount, :decimal
    field :status, Ecto.Enum, values: [:inactive, :active]

    timestamps()
  end

  def changeset(currency, attrs) do
    currency
    |> cast(attrs, [
      :amount,
      :user_id,
      :currency_id,
      :status
    ])
    |> validate_required([
      :amount,
      :user_id,
      :currency_id,
      :status
    ])
    |> validate_inclusion(:status, [:inactive, :active])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:currency_id)
  end
end
