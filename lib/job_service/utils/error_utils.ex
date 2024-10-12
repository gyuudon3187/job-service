defmodule JobService.ErrorUtils do
  import Plug.Conn
  import Ecto.Changeset, only: [traverse_errors: 2]

  def send_errors(conn, changeset) do
    errors = format_changeset_errors(changeset)
    send_resp(conn, 422, Jason.encode!(%{errors: errors}))
  end

  defp format_changeset_errors(changeset) do
    changeset
    |> traverse_errors(fn {msg, _opts} -> msg end)
    |> filter_empty_maps()
  end

  defp filter_empty_maps(%{skillset: skillset_errors} = errors) do
    %{errors | skillset: Enum.reject(skillset_errors, &(&1 == %{}))}
  end

  defp filter_empty_maps(errors), do: errors
end
