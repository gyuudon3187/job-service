defmodule JobService.Router.Skillset.InvalidTests.TwoOuterFieldsTest do
  @moduledoc """
  Tests with invalid payloads for the /skillset endpoint.
  Two fields per test in this module is invalid.
  """

  use ExUnit.Case
  import JobService.Router.{TestUtils, Skillset.TestUtils}
  import Mox
  doctest JobService.Router

  @valid_payload get_valid_payload()

  @moduletag expected_status: 422
  @moduletag payload: @valid_payload

  # fields
  @date_applied get_date_applied()
  @deadline get_deadline()

  setup [
    :set_value_for_key_in_payload,
    :set_value_for_second_key_in_payload,
    :set_expected_error_for_key,
    :setup_upsert_job_and_job_skillset_mock,
    :setup_delete_job_from_qdrant_mock,
    :verify_on_exit!,
    :do_test
  ]

  @current_date get_current_date_string()
  describe "POST /skillset with invalid combination of #{@date_applied} and #{@deadline}" do
    @tag key: @deadline
    @tag new_value: Date.utc_today() |> Date.add(-1) |> Date.to_string()
    @tag second_key: @date_applied
    @tag second_new_value: @current_date
    @tag expected_error: "MUST_BE_AFTER_DATE_APPLIED"
    test "(#{@date_applied} after #{@deadline})", context do
      assert_expected_errors_and_status(context)
    end
  end

  defp set_value_for_second_key_in_payload(%{
         payload: payload,
         second_key: key,
         second_new_value: value
       }) do
    set_value_for_key_in_payload(%{payload: payload, key: key, new_value: value})
  end
end
