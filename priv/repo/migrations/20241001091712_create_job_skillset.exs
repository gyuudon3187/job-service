defmodule JobService.Repo.Migrations.CreateJobSkillset do
  use Ecto.Migration

  def change do
    add :job_id, :integer
    add :skillset, :jsonb
    timestamps()
  end
end
