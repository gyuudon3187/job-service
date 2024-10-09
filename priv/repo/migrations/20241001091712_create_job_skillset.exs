defmodule JobService.Repo.Migrations.CreateJobSkillset do
  use Ecto.Migration

  def change do
    create table(:job_skillsets, primary_key: false) do
      add :job_id, references(:jobs, on_delete: :delete_all), primary_key: true
      add :user_email, :string, primary_key: true
      add :skillset, :jsonb
      timestamps()
    end
  end
end
