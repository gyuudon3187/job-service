defmodule JobService.RouterTest do
  use ExUnit.Case
  use Plug.Test
  doctest JobService.Router

  alias Plug.Conn
  alias JobService.Router

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
    conn = get_conn_with_jwt(@valid_skillset)

    # When
    conn = Router.call(conn, @opts)

    # Then
    assert conn.status == 200
    assert Jason.decode!(conn.resp_body) == %{"message" => "SUCCESS"}
  end

  describe "POST /skillset with malformed payload" do
    @describetag expected_error: "PAYLOAD_MALFORMED"
    @describetag expected_status: 400

    setup [:prepare_malformed_test, :do_invalid_test]

    @tag lacking_field: "jobId"
    test "(lacks jobId field)", context do
      assert_status_and_expected_errors(context)
    end

    @tag lacking_field: "skillset"
    test "(lacks skillset field)", context do
      assert_status_and_expected_errors(context)
    end
  end

  describe "POST /skillset with invalid jobId" do
    @describetag invalid_key: "jobId"
    @describetag expected_status: 422

    setup [:prepare_invalid_job_id_test, :do_invalid_test]

    @tag invalid_value: -1
    @tag expected_error: "NEGATIVE_ID"
    test "(negative)", context do
      assert_status_and_expected_errors(context)
    end

    @tag invalid_value: "A"
    @tag expected_error: "NOT_NUMBER"
    test "(non-numerical)", context do
      assert_status_and_expected_errors(context)
    end
  end

  describe "POST /skillset with invalid topic" do
    @describetag invalid_key: "topic"
    @describetag expected_status: 422
    @describetag skillset_index: 0

    setup [:prepare_invalid_skillset_test, :do_invalid_test]

    @tag invalid_value: 1
    @tag expected_error: "NOT_STRING"
    test "(non-string)", context do
      assert_status_and_expected_errors(context)
    end

    @tag invalid_value: "A"
    @tag expected_error: "TOO_SHORT"
    test "(too short)", context do
      assert_status_and_expected_errors(context)
    end
  end

  describe "POST /skillset with invalid importance" do
    @describetag invalid_key: "importance"
    @describetag expected_status: 422
    @describetag skillset_index: 0

    setup [:prepare_invalid_skillset_test, :do_invalid_test]

    @tag invalid_value: "10"
    @tag expected_error: "NOT_NUMBER"
    test "(non-number)", context do
      assert_status_and_expected_errors(context)
    end

    @tag invalid_value: 11
    @tag expected_error: "EXCEEDS_BOUNDS"
    test "(exceeding upper bound)", context do
      assert_status_and_expected_errors(context)
    end

    @tag invalid_value: -1
    @tag expected_error: "EXCEEDS_BOUNDS"
    test "(negative)", context do
      assert_status_and_expected_errors(context)
    end
  end

  defp assert_status_and_expected_errors(%{
         conn: conn,
         expected_errors: errors,
         expected_status: status
       }) do
    assert Jason.decode!(conn.resp_body) == %{"errors" => errors}
    assert conn.status == status
  end

  defp prepare_test(context, get_payload, get_expected_errors) do
    payload = get_payload.(context)
    expected_errors = get_expected_errors.(context)

    Map.merge(payload, expected_errors)
  end

  defp prepare_malformed_test(context) do
    prepare_test(context, &get_malformed_payload/1, &get_malformed_payload_expected_errors/1)
  end

  defp prepare_invalid_job_id_test(context) do
    prepare_test(context, &set_job_id_in_payload/1, &get_invalid_job_id_expected_errors/1)
  end

  defp prepare_invalid_skillset_test(context) do
    prepare_test(context, &get_invalid_skillset_payload/1, &get_skillset_expected_errors/1)
  end

  defp get_malformed_payload(%{lacking_field: field}) do
    %{payload: Map.delete(@valid_skillset, field)}
  end

  defp set_job_id_in_payload(%{invalid_value: job_id}) do
    %{payload: %{@valid_skillset | "jobId" => job_id}}
  end

  defp get_invalid_skillset_payload(%{
         invalid_key: key,
         invalid_value: value,
         skillset_index: index
       }) do
    %{payload: put_in(@valid_skillset, ["skillset", Access.at(index), key], value)}
  end

  defp get_malformed_payload_expected_errors(%{expected_error: error}) do
    %{expected_errors: error}
  end

  defp get_invalid_job_id_expected_errors(%{expected_error: error}) do
    expected_errors = %{
      "job_id" => error,
      "skillset" => []
    }

    %{expected_errors: expected_errors}
  end

  defp get_skillset_expected_errors(%{
         invalid_key: key,
         skillset_index: index,
         expected_error: error
       }) do
    expected_errors = %{
      "job_id" => nil,
      "skillset" => [
        %{"id" => index + 1, key => error}
      ]
    }

    %{expected_errors: expected_errors}
  end

  defp do_invalid_test(%{payload: payload, expected_errors: errors}) do
    # Given
    conn = get_conn_with_jwt(payload)

    # When
    conn = Router.call(conn, @opts)

    # Then
    %{expected_errors: errors, conn: conn}
  end

  @spec get_conn_with_jwt(map()) :: Conn.t()
  defp get_conn_with_jwt(payload) do
    conn(:post, "/skillset", payload)
    |> set_jwt_token()
  end

  @spec set_jwt_token(Conn.t()) :: Conn.t()
  defp set_jwt_token(conn) do
    put_req_header(conn, "authorization", "Bearer " <> @jwt)
  end
end
