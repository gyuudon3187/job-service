defmodule JobService.Router.Skillset.InvalidTests.OuterFieldsTest do
  @moduledoc """
  Tests with invalid payloads for the /skillset endpoint.
  """

  use ExUnit.Case
  import JobService.Router.{TestUtils, Skillset.TestUtils}
  import Mox
  doctest JobService.Router

  @moduletag expected_status: 422

  @valid_payload get_valid_payload()

  setup %{invalid_key: key, invalid_value: value, expected_error: error} do
    %{
      payload: %{@valid_payload | key => value},
      expected_errors: %{Macro.underscore(key) => [error]}
    }
  end

  setup [:setup_mock, :verify_on_exit!, :do_test]

  # describe "POST /skillset with invalid jobId" do
  #   @describetag invalid_key: "jobId"
  #   setup :do_test
  #
  #   @tag invalid_value: -1
  #   @tag expected_error: "NEGATIVE_ID"
  #   test "(negative)", context do
  #     assert_expected_errors_and_status(context)
  #   end
  #
  #   @tag invalid_value: "A"
  #   @tag expected_error: "NOT_NUMBER"
  #   test "(non-numerical)", context do
  #     assert_expected_errors_and_status(context)
  #   end
  # end

  describe "POST /skillset with invalid description" do
    @describetag invalid_key: "description"

    @tag invalid_value: 1
    @tag expected_error: "NOT_STRING"
    test "(non-string)", context do
      assert_expected_errors_and_status(context)
    end
  end
end
