defmodule JobService.Router.Skillset.ValidTest do
  @moduledoc """
  Tests with valid payloads for the /skillset endpoint.
  """

  use ExUnit.Case
  import JobService.Router.{TestUtils, Skillset.TestUtils}
  import Mox
  doctest JobService.Router

  setup [:setup_mock, :verify_on_exit!]

  @valid_payload get_valid_payload()

  describe "POST /skillset with valid data" do
    @describetag expected_status: 201

    setup [:prepare_successful_test, :do_test]

    test "(2 skills, all fields initialized except content)", context do
      assert_message_and_status(context)
    end
  end

  defp prepare_successful_test(_context) do
    %{payload: @valid_payload}
  end
end
