defmodule JobService.Router.Skillset.TestUtils do
  @moduledoc """
  Defines helper functions that are only inteded to be used by
  tests for the /skillset endpoint.
  """

  alias JobService.{Job, JobSkillset}
  import Mox

  @doc """
  Returns a payload with all require and optional fields initialized.
  """
  def get_valid_payload do
    %{
      "company" => "Amazon",
      "title" => "Software Architect",
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

  def get_company, do: "company"
  def get_description, do: "description"
  def get_url, do: "url"
  def get_date_applied, do: "date_applied"
  def get_deadline, do: "deadline"

  def get_current_date_string do
    Date.utc_today() |> Date.to_string()
  end

  def delete_field_from_payload(%{payload: payload, lacking_field: field}) do
    %{payload: Map.delete(payload, field)}
  end

  def set_expected_error(%{expected_error: error}) do
    %{expected_errors: error}
  end

  def set_expected_error_for_key(%{key: key, expected_error: error}) do
    %{expected_errors: %{Macro.underscore(key) => [error]}}
  end

  def set_value_for_key_in_payload(%{
        payload: payload,
        key: key,
        new_value: value
      }) do
    %{payload: %{payload | key => value}}
  end

  def setup_upsert_job_and_job_skillset_mock(_) do
    expect(JobService.MockRepo, :upsert_job_and_job_skillset, fn
      %{job: job, job_skillset: job_skillset} ->
        with {:ok, _} <- validate_job(job),
             {:ok, _} <- validate_job_skillset(job_skillset) do
          {:ok, %{job: job, job_skillset: job_skillset}}
        end
    end)

    :ok
  end

  def setup_delete_job_from_qdrant_mock(_) do
    expect(JobService.MockRepo, :delete_job_from_qdrant, fn _substituted_id, _token ->
      :ok
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
