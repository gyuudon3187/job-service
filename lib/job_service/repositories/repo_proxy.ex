defmodule JobService.RepoProxy do
  alias JobService.RepoBehaviour

  @behaviour RepoBehaviour

  @impl RepoBehaviour
  def delete_job_from_qdrant(id, token) do
    impl().delete_job_from_qdrant(id, token)
  end

  @impl RepoBehaviour
  def upsert_job_and_job_skillset(context) do
    impl().upsert_job_and_job_skillset(context)
  end

  defp impl, do: Application.get_env(:job_service, :repo_impl, JobService.RepoImpl)
end
