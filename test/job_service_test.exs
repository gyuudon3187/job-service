defmodule JobService.RouterTest do
  use ExUnit.Case
  use Plug.Test
  doctest JobService.Router

  alias Plug.Conn
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

  @spec get_invalid_conn(String.t(), any) :: Conn
  defp get_invalid_conn(field, value) do
    invalid_skillset = put_in(@valid_skillset, [field], value)
    conn(:post, "/skillset", invalid_skillset)
  end

  @spec get_invalid_conn(integer, String.t(), any) :: Conn
  defp get_invalid_conn(index, nested_field, value) do
    invalid_skillset =
      put_in(@valid_skillset, ["skillset", Access.at(index), nested_field], value)

    conn(:post, "/skillset", invalid_skillset)
  end

  describe "POST /skillset" do
    test "with valid data" do
      # Given
      conn = conn(:post, "/skillset", @valid_skillset)

      # When
      conn = Router.call(conn, @opts)

      # Then
      assert conn.status == 200
      assert Jason.decode!(conn.resp_body) == %{"message" => "SUCCESS"}
    end

    test "with invalid jobId" do
      # Given
      conn = get_invalid_conn("jobId", -1)

      # When
      conn = Router.call(conn, @opts)

      # Then
      assert conn.status == 400
      assert Jason.decode!(conn.resp_body) == %{"error" => %{"jobId" => "NEGATIVE_ID"}}
    end

    test "with invalid importance" do
      # Given
      conn = get_invalid_conn(0, "importance", 11)

      # When
      conn = Router.call(conn, @opts)

      # Then
      assert conn.status == 400
      assert Jason.decode!(conn.resp_body) == %{"error" => %{"importance" => "EXCEEDS_BOUNDS"}}
    end
  end
end
