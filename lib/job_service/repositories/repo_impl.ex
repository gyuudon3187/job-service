defmodule JobService.RepoImpl do
  alias JobService.Repo
  alias JobService.JobSkillset

  def save_job_skillset(job_skillset) do
    %JobSkillset{}
    |> JobSkillset.changeset(job_skillset)
    |> Repo.insert()
  end
end
