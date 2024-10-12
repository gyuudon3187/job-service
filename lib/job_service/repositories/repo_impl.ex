defmodule JobService.RepoImpl do
  alias JobService.Repo
  alias JobService.{Job, JobSkillset, Utils}
  alias Ecto.Multi

  def save_job_and_job_skillset(job, job_skillset) do
    job_skillset = Utils.to_string_keyed_map(job_skillset)

    Multi.new()
    |> Multi.insert(:job, Job.changeset(job))
    |> Multi.insert(:job_skillset, fn %{job: job} ->
      JobSkillset.changeset(Map.put(job_skillset, "job_id", job.id))
    end)
    |> Repo.transaction()
  end
end
