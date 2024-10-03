defmodule JobService.RouterTest do
  use ExUnit.Case
  use Plug.Test
  doctest JobService.Router

  alias Plug.Conn
  alias JobService.Router
  alias JobService.JobSkillset

  # test "interacts with the postgres container" do
  #   IO.puts("testing")
  #
  #   result =
  #     JobService.Repo.insert!(%JobService.JobSkill{
  #       job_id: 1,
  #       skillset: [%{topic: "test", importance: 8, type: "technical", content: "testtest"}]
  #     })
  #
  #   assert result.field == "value"
  # end

  @opts Router.init([])
  @jwt JobService.JWT.generate_and_sign!()
  @valid_skillset %{
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

  @spec get_invalid_conn_with_jwt(String.t(), any()) :: Conn.t()
  defp get_invalid_conn_with_jwt(field, value) do
    get_invalid_conn(field, value)
    |> set_jwt_token()
  end

  @spec get_invalid_conn_with_jwt(integer(), String.t(), any()) :: Conn.t()
  defp get_invalid_conn_with_jwt(index, nested_field, value) do
    get_invalid_conn(index, nested_field, value)
    |> set_jwt_token()
  end

  @spec get_invalid_conn(String.t(), any()) :: Conn.t()
  defp get_invalid_conn(field, value) do
    invalid_skillset = put_in(@valid_skillset, [field], value)
    prepare_post_skillset(invalid_skillset)
  end

  @spec get_invalid_conn(integer(), String.t(), any()) :: Conn.t()
  defp get_invalid_conn(index, nested_field, value) do
    invalid_skillset =
      put_in(@valid_skillset, ["skillset", Access.at(index), nested_field], value)

    prepare_post_skillset(invalid_skillset)
  end

  @spec prepare_post_skillset(JobSkillset.t()) :: Conn.t()
  defp prepare_post_skillset(payload), do: conn(:post, "/skillset", payload)

  @spec set_jwt_token(Conn.t()) :: Conn.t()
  defp set_jwt_token(conn) do
    put_req_header(conn, "authorization", "Bearer " <> @jwt)
  end

  describe "POST /skillset" do
    test "with valid data" do
      # Given
      conn = conn(:post, "/skillset", @valid_skillset) |> set_jwt_token()

      # When
      conn = Router.call(conn, @opts)

      # Then
      assert conn.status == 200
      assert Jason.decode!(conn.resp_body) == %{"message" => "SUCCESS"}
    end

    test "with invalid job_id" do
      # Given
      conn = get_invalid_conn_with_jwt("jobId", -1)

      # When
      conn = Router.call(conn, @opts)

      # Then
      expected_errors = %{"job_id" => "NEGATIVE_ID", "skillset" => []}
      assert conn.status == 422
      assert Jason.decode!(conn.resp_body) == %{"errors" => expected_errors}
    end

    test "with invalid importance" do
      # Given
      conn = get_invalid_conn_with_jwt(0, "importance", 11)

      # When
      conn = Router.call(conn, @opts)

      # Then
      expected_errors = %{
        "job_id" => nil,
        "skillset" => [%{"id" => 1, "importance" => "EXCEEDS_BOUNDS"}]
      }

      assert conn.status == 422
      assert Jason.decode!(conn.resp_body) == %{"errors" => expected_errors}
    end
  end
end
