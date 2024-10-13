defmodule JobService.Router.Skillset.InvalidTests.OuterFieldsWithoutMockTest do
  @moduledoc """
  Testing with invalid payloads for the /skillset endpoint.
  Tests outer fields without mocking the database.
  One field per test in this module is invalid.
  """

  use ExUnit.Case
  import JobService.Router.{TestUtils, Skillset.TestUtils}
  doctest JobService.Router

  @valid_payload get_valid_payload()

  @moduletag payload: @valid_payload

  describe "POST /skillset with malformed payload" do
    @describetag expected_error: "PAYLOAD_MALFORMED"
    @describetag expected_status: 400

    setup [:delete_field_from_payload, :set_expected_error, :do_test]

    @tag lacking_field: "description"
    test "(lacks description field)", context do
      assert_expected_errors_and_status(context)
    end

    @tag lacking_field: "url"
    test "(lacks url field)", context do
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

    setup [:set_expected_error, :do_test]

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
