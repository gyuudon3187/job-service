defmodule JobService.Utils do
  @moduledoc """
  Module for general utilities.
  """

  @spec to_snake_case_keys(map()) :: map()
  def to_snake_case_keys(map) when is_map(map) do
    map
    |> Enum.map(fn {key, value} ->
      {to_snake_case_key(key), transform_value(value)}
    end)
    |> Enum.into(%{})
  end

  defp transform_value(value) when is_map(value), do: to_snake_case_keys(value)
  defp transform_value(value) when is_list(value), do: Enum.map(value, &transform_value/1)
  defp transform_value(value), do: value

  defp to_snake_case_key(key) when is_atom(key),
    do: key |> Atom.to_string() |> Macro.underscore() |> String.to_atom()

  defp to_snake_case_key(key) when is_binary(key), do: key |> Macro.underscore()
  defp to_snake_case_key(key), do: key
end
