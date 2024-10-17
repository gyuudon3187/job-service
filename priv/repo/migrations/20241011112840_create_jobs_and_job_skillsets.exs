defmodule JobService.Repo.Migrations.CreateJobsAndJobSkillsets do
  use Ecto.Migration

  def change do
    create table(:job_skillsets, primary_key: false) do
      add :job_id, :string, primary_key: true
      add :user_email, :string, primary_key: true
      add :company, :string
      add :title, :string, null: false
      add :url, :string, null: false
      add :date_applied, :date
      add :deadline, :date
      add :skillset, :jsonb
      timestamps()
    end
  end
end
