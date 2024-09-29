defmodule JobServiceTest do
  use ExUnit.Case
  use Plug.Test
  doctest JobService

  alias JobService.Router

  @opts Router.init([])
  @valid_skillset %{
    "jobId" => 1,
    "skillset" => [
      %{
        "topic" => "Experience in serverless architecture and AWS",
        "importance" => 9,
        "type" => "technical"
      },
      %{
        "topic" => "Working in an agile environment with Scrum or Kanban",
        "importance" => 7,
        "type" => "project management"
      }
    ]
  }

  describe "POST /skillset" do
    test "with valid data" do
      # Given
      conn = conn(:post, "/skillset", @valid_skillset)

      # When
      conn = Router.call(conn, @opts)

      # Then
      assert conn.status == 200
      assert conn.resp_body == "Data saved successfully"
    end
  end
end
