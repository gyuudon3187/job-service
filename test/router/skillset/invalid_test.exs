defmodule JobService.Router.Skillset.InvalidTest do
  use ExUnit.Case
  import JobService.Router.{TestUtils, Skillset.TestUtils}
  doctest JobService.Router

  @valid_payload get_valid_payload()

  describe "POST /skillset with malformed payload" do
    @describetag expected_error: "PAYLOAD_MALFORMED"
    @describetag expected_status: 400

    setup [:prepare_malformed_test, :do_test]

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

    setup [:prepare_invalid_job_id_test, :do_test]

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

    setup [:prepare_invalid_skillset_test, :do_test]

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

    setup [:prepare_invalid_skillset_test, :do_test]

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

  defp prepare_malformed_test(context) do
    prepare_test(
      context,
      &delete_field_in_valid_payload/1,
      &get_malformed_payload_expected_errors/1
    )
  end

  defp prepare_invalid_job_id_test(context) do
    prepare_test(
      context,
      &replace_valid_job_id_with_invalid_value/1,
      &get_invalid_job_id_expected_errors/1
    )
  end

  defp prepare_invalid_skillset_test(context) do
    prepare_test(
      context,
      &replace_valid_skillset_field_with_invalid_value/1,
      &get_invalid_skillset_expected_errors/1
    )
  end

  defp delete_field_in_valid_payload(%{lacking_field: field}) do
    %{payload: Map.delete(@valid_payload, field)}
  end

  defp replace_valid_job_id_with_invalid_value(%{invalid_value: job_id}) do
    %{payload: %{@valid_payload | "jobId" => job_id}}
  end

  defp replace_valid_skillset_field_with_invalid_value(%{
         invalid_key: key,
         invalid_value: value,
         skillset_index: index
       }) do
    %{payload: put_in(@valid_payload, ["skillset", Access.at(index), key], value)}
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

  defp get_invalid_skillset_expected_errors(%{
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
end
