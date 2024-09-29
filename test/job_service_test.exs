defmodule JobServiceTest do
  use ExUnit.Case
  doctest JobService

  test "greets the world" do
    assert JobService.hello() == :world
  end
end
