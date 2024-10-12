defmodule JobService.Router.Skillset.TestUtils do
  @moduledoc """
  Defines helper functions that are only inteded to be used by
  tests for the /skillset endpoint.
  """

  alias JobService.{Job, JobSkillset, Utils}
  import Mox

  @doc """
  Returns a payload with all require and optional fields initialized.
  """
  def get_valid_payload do
    %{
      "company" => "Amazon",
      "description" =>
        "We require experience in serverless architecture and AWS. It's also good if you're familiar with Scrum or Kanban.",
      "url" => "https://somewebsite.com",
      "date_applied" => Date.utc_today() |> Date.add(-1) |> Date.to_string(),
      "deadline" => Date.utc_today() |> Date.add(1) |> Date.to_string(),
      "skillset" => [
        %{
          "topic" => "Experience in serverless architecture and AWS",
          "importance" => 9,
          "type" => "technical",
          "content" => "Some text"
        },
        %{
          "topic" => "Working in an agile environment with Scrum or Kanban",
          "importance" => 7,
          "type" => "project_management",
          "content" => "Some text"
        }
      ]
    }
  end

  def setup_save_job_and_job_skillset_mock(_) do
    expect(JobService.MockRepo, :save_job_and_job_skillset, fn job, job_skillset ->
      job = Utils.to_string_keyed_map(job)
      job_skillset = Utils.to_string_keyed_map(job_skillset)
      job_id = Enum.random(1..100)
      updated_job_skillset = Map.put(job_skillset, "job_id", job_id)

      with {:ok, _} <- validate_job(job),
           {:ok, _} <- validate_job_skillset(updated_job_skillset) do
        updated_job = Map.put(job, "id", job_id)

        {:ok, %{job: updated_job, job_skillset: updated_job_skillset}}
      end
    end)

    :ok
  end

  defp validate_job(job) do
    job_changeset = Job.changeset(job)

    if job_changeset.valid? do
      {:ok, nil}
    else
      {:error, nil, job_changeset, nil}
    end
  end

  defp validate_job_skillset(job_skillset) do
    job_skillset_changeset = JobSkillset.changeset(job_skillset)

    if job_skillset_changeset.valid? do
      {:ok, nil}
    else
      {:error, nil, job_skillset_changeset, nil}
    end
  end
end
