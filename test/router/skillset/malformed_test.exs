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

    setup %{lacking_field: field, expected_error: error} do
      %{
        payload: Map.delete(@valid_payload, field),
        expected_errors: error
      }
    end

    setup :do_test

    @tag lacking_field: "jobId"
    test "(lacks jobId field)", context do
      assert_expected_errors_and_status(context)
    end

    @tag lacking_field: "skillset"
    test "(lacks skillset field)", context do
      assert_expected_errors_and_status(context)
    end
  end

  describe "POST /skillset with invalid email" do
    @describetag expected_status: 401
    @describetag expected_error: "INVALID_TOKEN"

    setup %{expected_error: error} do
      %{payload: @valid_payload, expected_errors: error}
    end

    setup :do_test

    @tag invalid_email: "@example.com"
    test "(no username)", context do
      assert_expected_errors_and_status(context)
    end

    @tag invalid_email: "userexample.com"
    test "(no @)", context do
      assert_expected_errors_and_status(context)
    end

    @tag invalid_email: "user@example"
    test "(no TLD)", context do
      assert_expected_errors_and_status(context)
    end

    @tag invalid_email: "user@.com"
    test "(no domain)", context do
      assert_expected_errors_and_status(context)
    end

    @tag invalid_email: "user@"
    test "(no FQDN)", context do
      assert_expected_errors_and_status(context)
    end
  end
end
