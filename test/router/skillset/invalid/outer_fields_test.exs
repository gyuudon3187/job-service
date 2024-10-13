defmodule JobService.Router.Skillset.InvalidTests.OuterFieldsTest do
  @moduledoc """
  Tests with invalid payloads for the /skillset endpoint.
  One field per test in this module is invalid.
  """

  use ExUnit.Case
  import JobService.Router.{TestUtils, Skillset.TestUtils}
  import Mox
  doctest JobService.Router

  @valid_payload get_valid_payload()

  @moduletag expected_status: 422
  @moduletag payload: @valid_payload

  # fields
  @company get_company()
  @description get_description()
  @url get_url()
  @date_applied get_date_applied()
  @deadline get_deadline()

  setup [
    :set_value_for_key_in_payload,
    :set_expected_error_for_key,
    :setup_save_job_and_job_skillset_mock,
    :verify_on_exit!,
    :do_test
  ]

  describe "POST /skillset with invalid #{@company}" do
    @describetag key: @company

    @tag new_value: 1
    @tag expected_error: "NOT_STRING"
    test "(non-string)", context do
      assert_expected_errors_and_status(context)
    end
  end

  describe "POST /skillset with invalid #{@description}" do
    @describetag key: @description

    @tag new_value: 1
    @tag expected_error: "NOT_STRING"
    test "(non-string)", context do
      assert_expected_errors_and_status(context)
    end
  end

  describe "POST /skillset with invalid #{@url}" do
    @describetag key: @url
    @describetag expected_error: "NOT_URL"

    @tag new_value: 1
    @tag expected_error: "NOT_STRING"
    test "(non-string)", context do
      assert_expected_errors_and_status(context)
    end

    @tag new_value: "htttp://example.com"
    test "(invalid protocol)", context do
      assert_expected_errors_and_status(context)
    end

    @tag new_value: "http//example.com"
    test "(no colon in scheme)", context do
      assert_expected_errors_and_status(context)
    end

    @tag new_value: "http:/example.com"
    test "(simple instead of double slash in scheme)", context do
      assert_expected_errors_and_status(context)
    end

    @tag new_value: "http://examplecom"
    test "(no TLD)", context do
      assert_expected_errors_and_status(context)
    end
  end

  @current_date get_current_date_string()
  describe "POST /skillset with invalid #{@date_applied}" do
    @describetag key: @date_applied
    @describetag expected_error: "NOT_DATE"

    @tag new_value: @current_date |> String.replace("-", "")
    test "(format: YYYYMMDD)", context do
      assert_expected_errors_and_status(context)
    end

    @tag new_value: @current_date |> String.replace("-", "_")
    test "(format: YYYY_MM_DD)", context do
      assert_expected_errors_and_status(context)
    end

    @tag new_value: @current_date |> String.slice(2..-1//1)
    test "(format: YYMMDD)", context do
      assert_expected_errors_and_status(context)
    end
  end

  describe "POST /skillset with invalid #{@deadline}" do
    @describetag key: @deadline
    @describetag expected_error: "NOT_DATE"

    @tag new_value: @current_date |> String.replace("-", "")
    test "(format: YYYYMMDD)", context do
      assert_expected_errors_and_status(context)
    end

    @tag new_value: @current_date |> String.replace("-", "_")
    test "(format: YYYY_MM_DD)", context do
      assert_expected_errors_and_status(context)
    end

    @tag new_value: @current_date |> String.slice(2..-1//1)
    test "(format: YYMMDD)", context do
      assert_expected_errors_and_status(context)
    end
  end
end
