defmodule JobService.Router.Skillset.TestUtils do
  @moduledoc """
  Defines helper functions that are only inteded to be used by
  tests for the /skillset endpoint.
  """

  @doc """
  Returns a payload with all required (but not all optional)
  fields initialized.
  """
  def get_valid_payload do
    %{
      "jobId" => 1,
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
end
