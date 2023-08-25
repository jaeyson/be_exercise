defmodule BeExercise.Repo.Migrations.CreateCurrencies do
  use Ecto.Migration

  def change do
    create table(:currencies) do
      add :code, :string, null: false
      add :name, :string, null: false
      timestamps()
    end

    alter table(:salaries) do
      add :currency_id, references(:currencies, on_delete: :delete_all), null: false
    end

    create unique_index(:currencies, [:code])
    create index(:salaries, [:currency_id])
  end
end
