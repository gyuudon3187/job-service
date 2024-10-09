defmodule JobService.Router.Skillset.MalformedTest do
  @moduledoc """
  Tests with malformed payloads for the /skillset endpoint.
  """

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
      assert_expected_errors_and_status(context)
    end

    @tag lacking_field: "skillset"
    test "(lacks skillset field)", context do
      assert_expected_errors_and_status(context)
    end
  end

  defp prepare_malformed_test(context) do
    prepare_test(
      context,
      &delete_field_in_valid_payload/1,
      &get_malformed_payload_expected_errors/1
    )
  end

  defp delete_field_in_valid_payload(%{lacking_field: field}) do
    %{payload: Map.delete(@valid_payload, field)}
  end

  defp get_malformed_payload_expected_errors(%{expected_error: error}) do
    %{expected_errors: error}
  end
end
