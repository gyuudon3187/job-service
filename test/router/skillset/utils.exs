defmodule JobService.Router.Skillset.TestUtils do
  @moduledoc """
  Defines helper functions that are only inteded to be used by
  tests for the /skillset endpoint.
  """

  alias JobService.JobSkillset
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

  def setup_mock(_) do
    expect(JobService.MockRepo, :save_job_skillset, fn payload ->
      changeset = JobSkillset.changeset(%JobSkillset{}, payload)

      if changeset.valid? do
        {:ok, put_in(payload, [:id], 1)}
      else
        {:error, changeset}
      end
    end)

    :ok
  end
end
