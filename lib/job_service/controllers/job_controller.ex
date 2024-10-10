defmodule JobService.JobController do
  alias JobService.RepoProxy
  import Plug.Conn
  import Ecto.Changeset, only: [traverse_errors: 2]

  def handle_skillset_request(conn) do
    case conn.body_params do
      %{"description" => description, "url" => url, "skillset" => skillset} = params ->
        case RepoProxy.save_job_skillset(%{
               job_id: 1,
               user_email: conn.assigns[:email],
               description: description,
               url: url,
               skillset: skillset,
               date_applied: params["date_applied"],
               deadline: params["deadline"]
             }) do
          {:ok, _result} ->
            send_resp(conn, 201, Jason.encode!(%{message: "SUCCESS"}))

          {:error, changeset} ->
            errors = format_changeset_errors(changeset)
            send_resp(conn, 422, Jason.encode!(%{errors: errors}))
        end

      _ ->
        send_resp(conn, 400, Jason.encode!(%{errors: "PAYLOAD_MALFORMED"}))
    end
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
