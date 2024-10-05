defmodule JobService.Router.Skillset.ValidTest do
  use ExUnit.Case
  import JobService.Router.{TestUtils, Skillset.TestUtils}
  doctest JobService.Router

  @valid_skillset get_valid_skillset()

  describe "POST /skillset with valid data" do
    @describetag expected_status: 200

    setup [:prepare_successful_test, :do_test]

    test "(just testing)", context do
      assert_status_and_expected_errors(context)
    end
  end

  defp prepare_successful_test(_context) do
    %{payload: @valid_skillset}
  end
end
