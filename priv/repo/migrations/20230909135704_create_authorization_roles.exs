defmodule BeExercise.Repo.Migrations.CreateAuthorizationRoles do
  use Ecto.Migration

  def change do
    create table(:authorization_roles) do
      add :name, :string, null: false
      timestamps()
    end

    alter table(:users) do
      add :authorization_role_id,
          references(:authorization_roles, on_delete: :delete_all, on_update: :update_all),
          null: false
    end

    create unique_index(:authorization_roles, [:name])
    create index(:users, [:authorization_role_id])
  end
end
