defmodule JobService.RouterTest do
  use ExUnit.Case
  use Plug.Test
  doctest JobService.Router

  alias Plug.Conn
  alias JobService.Router

  @type skillset_for_job :: %{jobId: integer(), skillset: skillset()}
  @type skillset :: list(skill())
  @type skill :: %{
          topic: String.t(),
          importance: integer(),
          type: skill_type(),
          content: String.t()
        }
  @type skill_type ::
          :problem_solving
          | :communication
          | :project_management
          | :security
          | :teamwork
          | :adaptability
          | :customer_focus

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
        "type" => "project management",
        "content" => "Some text"
      }
    ]
  }

  @spec get_invalid_conn_with_jwt(String.t(), any()) :: Conn
  defp get_invalid_conn_with_jwt(field, value) do
    get_invalid_conn(field, value)
    |> set_jwt_token()
  end

  @spec get_invalid_conn_with_jwt(integer(), String.t(), any()) :: Conn
  defp get_invalid_conn_with_jwt(index, nested_field, value) do
    get_invalid_conn(index, nested_field, value)
    |> set_jwt_token()
  end

  @spec get_invalid_conn(String.t(), any()) :: Conn
  defp get_invalid_conn(field, value) do
    invalid_skillset = put_in(@valid_skillset, [field], value)
    prepare_post_skillset(invalid_skillset)
  end

  @spec get_invalid_conn(integer(), String.t(), any()) :: Conn
  defp get_invalid_conn(index, nested_field, value) do
    invalid_skillset =
      put_in(@valid_skillset, ["skillset", Access.at(index), nested_field], value)

    prepare_post_skillset(invalid_skillset)
  end

  @spec prepare_post_skillset(skillset_for_job()) :: Conn
  defp prepare_post_skillset(payload), do: conn(:post, "/skillset", payload)

  @spec set_jwt_token(Conn) :: Conn
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

    test "with invalid jobId" do
      # Given
      conn = get_invalid_conn_with_jwt("jobId", -1)

      # When
      conn = Router.call(conn, @opts)

      # Then
      assert conn.status == 422
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
