defmodule JobService.Repo.Migrations.CreateJobs do
  use Ecto.Migration

  def change do
    create table :jobs do
      add :description, :string
      timestamps()
    end
  end
end
