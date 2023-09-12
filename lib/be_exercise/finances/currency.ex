defmodule BeExercise.Finances.Currency do
  @moduledoc """
  Currency schema and changesets
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "currencies" do
    field :code, :string
    field :name, :string
    timestamps()
  end

  def changeset(currency, attrs) do
    currency
    |> cast(attrs, [
      :code,
      :name
    ])
    |> validate_required([
      :code,
      :name
    ])
    |> unique_constraint(:code)
  end
end
