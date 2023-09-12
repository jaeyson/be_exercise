defmodule BeExercise.Accounts.AuthorizationRole do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias BeExercise.Accounts.User

  schema "authorization_roles" do
    field :name, :string
    has_many :users, User
    timestamps()
  end

  def changeset(authorization_role, attrs) do
    authorization_role
    |> cast(attrs, [
      :name
    ])
    |> validate_required([
      :name
    ])
    |> unique_constraint(:name)
  end
end
