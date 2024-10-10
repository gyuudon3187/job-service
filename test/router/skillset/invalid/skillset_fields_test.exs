defmodule JobService.Router.Skillset.InvalidTests.SkillsetFieldsTest do
  @moduledoc """
  Testing with invalid payloads for the /skillset endpoint.
  Tests the fields inside the payload's skillset field.
  """

  use ExUnit.Case
  import JobService.Router.{TestUtils, Skillset.TestUtils}
  import Mox
  doctest JobService.Router

  @moduletag expected_status: 422

  @valid_payload get_valid_payload()

  setup [
    :setup_mock,
    :verify_on_exit!,
    :replace_valid_skillset_field_with_invalid_value,
    :get_invalid_skillset_expected_errors,
    :do_test
  ]

  describe "POST /skillset with invalid topic" do
    @describetag invalid_key: "topic"
    @describetag skillset_index: 0

    @tag invalid_value: 1
    @tag expected_error: "NOT_STRING"
    test "(non-string)", context do
      assert_expected_errors_and_status(context)
    end

    @tag invalid_value: "A"
    @tag expected_error: "TOO_SHORT"
    test "(too short)", context do
      assert_expected_errors_and_status(context)
    end
  end

  describe "POST /skillset with invalid importance" do
    @describetag invalid_key: "importance"
    @describetag skillset_index: 0

    @tag invalid_value: "A"
    @tag expected_error: "NOT_NUMBER"
    test "(non-number)", context do
      assert_expected_errors_and_status(context)
    end

    @tag invalid_value: 11
    @tag expected_error: "EXCEEDS_BOUNDS"
    test "(exceeding upper bound)", context do
      assert_expected_errors_and_status(context)
    end

    @tag invalid_value: -1
    @tag expected_error: "EXCEEDS_BOUNDS"
    test "(negative)", context do
      assert_expected_errors_and_status(context)
    end
  end

  describe "POST /skillset with invalid type" do
    @describetag invalid_key: "type"
    @describetag skillset_index: 0

    @tag invalid_value: "technicalq"
    @tag expected_error: "NOT_TYPE"
    test "(non-existent type)", context do
      assert_expected_errors_and_status(context)
    end
  end

  describe "POST /skillset with invalid content" do
    @describetag invalid_key: "content"
    @describetag skillset_index: 0

    @tag invalid_value: 1
    @tag expected_error: "NOT_STRING"
    test "(non-string)", context do
      assert_expected_errors_and_status(context)
    end
  end

  defp replace_valid_skillset_field_with_invalid_value(%{
         invalid_key: key,
         invalid_value: value,
         skillset_index: index
       }) do
    %{payload: put_in(@valid_payload, ["skillset", Access.at(index), key], value)}
  end

  defp get_invalid_skillset_expected_errors(%{
         invalid_key: key,
         expected_error: error
       }) do
    %{expected_errors: %{"skillset" => [%{key => [error]}]}}
  end
end
