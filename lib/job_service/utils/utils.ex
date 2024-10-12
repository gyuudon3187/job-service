defmodule JobService.Utils do
  @moduledoc """
  Module for general utilities.
  """

  @doc """
  Turns any keys inside a map into strings.
  """
  @spec to_string_keyed_map(map()) :: map()
  def to_string_keyed_map(map) do
    map |> Jason.encode!() |> Jason.decode!()
  end
end
