defmodule JobService.Repo.Migrations.CreateJobsAndJobSkillsets do
  use Ecto.Migration

  def change do
    create table(:jobs) do
      add :description, :string, null: false
      timestamps()
    end

    create table(:job_skillsets, primary_key: false) do
      add :job_id, references(:jobs, on_delete: :delete_all), primary_key: true
      add :user_email, :string, primary_key: true
      add :url, :string, null: false
      add :date_applied, :date
      add :deadline, :date
      add :skillset, :jsonb
      timestamps()
    end
  end
end
