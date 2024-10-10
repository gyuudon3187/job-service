defmodule JobService.Router.Skillset.ValidTest do
  @moduledoc """
  Tests with valid payloads for the /skillset endpoint.
  """

  use ExUnit.Case
  import JobService.Router.{TestUtils, Skillset.TestUtils}
  import Mox
  doctest JobService.Router

  setup [:setup_mock, :verify_on_exit!]

  @moduletag expected_status: 201

  @valid_payload get_valid_payload()

  describe "POST /skillset with valid data" do
    setup [:prepare_successful_test, :do_test]

    test "(2 skills, all fields initialized except content)", context do
      assert_message_and_status(context)
    end
  end

  describe "POST /skillset with valid URL" do
    setup [:set_url, :do_test]

    @tag url: "http://example.com"
    test "(protocol: http)", context do
      assert_message_and_status(context)
    end

    @tag url: "https://example.com"
    test "(protocol: https)", context do
      assert_message_and_status(context)
    end

    @tag url: "example.com"
    test "(without scheme)", context do
      assert_message_and_status(context)
    end

    @tag url: "http://example.com/"
    test "(trailing slash)", context do
      assert_message_and_status(context)
    end

    @tag url: "http://example.com/path/with_some_special_characters?query=dummy"
    test "(with path)", context do
      assert_message_and_status(context)
    end
  end

  defp set_url(%{url: url}) do
    %{payload: %{@valid_payload | "url" => url}}
  end

  defp prepare_successful_test(_context) do
    %{payload: @valid_payload}
  end
end
