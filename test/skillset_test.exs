defmodule JobService.RouterTest do
  use ExUnit.Case
  use Plug.Test
  doctest JobService.Router

  alias Plug.Conn
  alias JobService.Router
  alias JobService.JobSkillset

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

  test "POST /skillset with valid data" do
    # Given
    conn = conn(:post, "/skillset", @valid_skillset) |> set_jwt_token()

    # When
    conn = Router.call(conn, @opts)

    # Then
    assert conn.status == 200
    assert Jason.decode!(conn.resp_body) == %{"message" => "SUCCESS"}
  end

  describe "POST /skillset with invalid jobId" do
    @describetag invalid_key: "jobId"

    setup [:get_invalid_test, :do_invalid_test]

    @tag invalid_value: -1
    @tag expected_error: "NEGATIVE_ID"
    test "(non-string)", context do
      assert_status_422_and_expected_errors(context.conn, context.expected_errors)
    end
  end

  describe "POST /skillset with invalid topic" do
    @describetag invalid_key: "topic"
    @describetag skillset_index: 0

    setup [:get_invalid_test, :do_invalid_test]

    @tag invalid_value: 1
    @tag expected_error: "NOT_STRING"
    test "(non-string)", context do
      assert_status_422_and_expected_errors(context.conn, context.expected_errors)
    end
  end

  describe "POST /skillset with invalid importance" do
    @describetag invalid_key: "importance"
    @describetag skillset_index: 0

    setup [:get_invalid_test, :do_invalid_test]

    @tag invalid_value: "10"
    @tag expected_error: "NOT_NUMBER"
    test "(non-number)", context do
      assert_status_422_and_expected_errors(context.conn, context.expected_errors)
    end

    @tag invalid_value: 11
    @tag expected_error: "EXCEEDS_BOUNDS"
    test "(exceeding upper bound)", context do
      assert_status_422_and_expected_errors(context.conn, context.expected_errors)
    end

    @tag invalid_value: -1
    @tag expected_error: "EXCEEDS_BOUNDS"
    test "(negative)", context do
      assert_status_422_and_expected_errors(context.conn, context.expected_errors)
    end
  end

  defp assert_status_422_and_expected_errors(conn, expected_errors) do
    assert conn.status == 422
    assert Jason.decode!(conn.resp_body) == %{"errors" => expected_errors}
  end

  defp get_invalid_test(%{
         invalid_key: key,
         skillset_index: index
       }) do
    invalid_skillset_test = fn value, expected_error ->
      # Given
      conn = get_invalid_conn_with_jwt(index, key, value)

      # When
      conn = Router.call(conn, @opts)

      # Then
      expected_errors = %{
        "job_id" => nil,
        "skillset" => [
          %{"id" => index + 1, key => expected_error}
        ]
      }

      %{expected_errors: expected_errors, conn: conn}
    end

    %{invalid_test: invalid_skillset_test}
  end

  defp get_invalid_test(%{
         invalid_key: key
       }) do
    invalid_skillset_test = fn value, expected_error ->
      # Given
      conn = get_invalid_conn_with_jwt(key, value)

      # When
      conn = Router.call(conn, @opts)

      # Then
      expected_errors = %{
        "job_id" => expected_error,
        "skillset" => []
      }

      %{expected_errors: expected_errors, conn: conn}
    end

    %{invalid_test: invalid_skillset_test}
  end

  defp do_invalid_test(%{
         invalid_test: invalid_test,
         invalid_value: value,
         expected_error: expected_error
       }),
       do: invalid_test.(value, expected_error)

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
end
