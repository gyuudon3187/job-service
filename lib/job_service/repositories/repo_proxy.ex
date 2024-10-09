defmodule JobService.RepoProxy do
  alias JobService.RepoBehaviour

  @behaviour RepoBehaviour

  @impl RepoBehaviour
  def save_job_skillset(job_skillset) do
    impl().save_job_skillset(job_skillset)
  end

  defp impl, do: Application.get_env(:job_service, :repo_impl, JobService.RepoImpl)
end
