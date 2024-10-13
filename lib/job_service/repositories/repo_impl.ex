defmodule JobService.RepoImpl do
  alias JobService.Repo
  alias JobService.{Job, JobSkillset}
  alias Ecto.Multi

  def save_job_and_job_skillset(job, job_skillset) do
    Multi.new()
    |> Multi.insert_or_update(:job, Job.changeset(job))
    |> Multi.insert_or_update(
      :job_skillset,
      fn %{job: job} -> JobSkillset.changeset(Map.put(job_skillset, "job_id", job.id)) end
    )
    |> Repo.transaction()
  end
end
