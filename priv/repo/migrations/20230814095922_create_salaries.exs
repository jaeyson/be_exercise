defmodule BeExercise.Repo.Migrations.CreateSalaries do
  use Ecto.Migration

  def change do
    create table(:salaries) do
      add :amount, :decimal, null: false
      add :status, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      timestamps()
    end
  end
end
