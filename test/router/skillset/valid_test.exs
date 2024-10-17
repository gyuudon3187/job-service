defmodule JobService.Router.Skillset.ValidTest do
  @moduledoc """
  Tests with valid payloads for the /skillset endpoint.
  """

  use ExUnit.Case
  import JobService.Router.{TestUtils, Skillset.TestUtils}
  import Mox
  doctest JobService.Router

  setup [
    :setup_upsert_job_and_job_skillset_mock,
    :verify_on_exit!
  ]

  @valid_payload get_valid_payload()

  @moduletag expected_status: 200
  @moduletag payload: @valid_payload

  # fields
  @url get_url()
  @date_applied get_date_applied()
  @deadline get_deadline()

  describe "POST /skillset with valid data" do
    setup :do_test

    test "(2 skills, all fields initialized)", context do
      assert_message_and_status(context)
    end
  end

  describe "POST /skillset without optional field" do
    setup [:delete_field_from_payload, :do_test]

    @tag lacking_field: @date_applied
    test "'#{@date_applied}'", context do
      assert_message_and_status(context)
    end

    @tag lacking_field: @deadline
    test "'#{@deadline}'", context do
      assert_message_and_status(context)
    end
  end

  describe "POST /skillset with valid #{@url}" do
    @describetag key: @url

    setup [:set_value_for_key_in_payload, :do_test]

    @tag new_value: "http://example.com"
    test "(protocol: http)", context do
      assert_message_and_status(context)
    end

    @tag new_value: "https://example.com"
    test "(protocol: https)", context do
      assert_message_and_status(context)
    end

    @tag new_value: "example.com"
    test "(without scheme)", context do
      assert_message_and_status(context)
    end

    @tag new_value: "http://example.com/"
    test "(trailing slash)", context do
      assert_message_and_status(context)
    end

    @tag new_value: "http://example.com/path/with_some_special_characters?query=dummy"
    test "(with path)", context do
      assert_message_and_status(context)
    end
  end

  @current_date get_current_date_string()
  describe "POST /skillset with valid date_applied" do
    @describetag key: @date_applied

    setup [:set_value_for_key_in_payload, :do_test]

    @tag new_value: @current_date
    test "(YYYY-MM-DD)", context do
      assert_message_and_status(context)
    end
  end
end
