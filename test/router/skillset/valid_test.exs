defmodule JobService.Router.Skillset.ValidTest do
  use ExUnit.Case
  import JobService.Router.{TestUtils, Skillset.TestUtils}
  doctest JobService.Router

  @valid_payload get_valid_payload()

  describe "POST /skillset with valid data" do
    @describetag expected_status: 200

    setup [:prepare_successful_test, :do_test]

    test "(2 skills, all fields initialized except content)", context do
      assert_message_and_status(context)
    end
  end

  defp prepare_successful_test(_context) do
    %{payload: @valid_payload}
  end
end
