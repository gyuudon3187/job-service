defmodule JobService.JobController do
  alias JobService.{Utils, ErrorUtils, RepoProxy}
  import Plug.Conn

  def handle_skillset_request(conn) do
    params = conn.body_params |> Utils.to_snake_case_keys()

    case params do
      %{"description" => description, "title" => title, "url" => url, "skillset" => skillset} ->
        job_id = UUID.uuid4()
        company = params["company"]
        user_email = conn.assigns[:email]
        substituted_id = params["substituted_id"]
        token = conn.assigns[:token]

        job = %{
          "id" => job_id,
          "description" => description,
          "company" => company,
          "title" => title,
          "url" => url
        }

        job_skillset = %{
          "job_id" => job_id,
          "user_email" => user_email,
          "company" => params["company"],
          "title" => title,
          "description" => description,
          "url" => url,
          "skillset" => skillset,
          "date_applied" => params["date_applied"],
          "deadline" => params["deadline"]
        }

        RepoProxy.upsert_job_and_job_skillset(%{
          job: job,
          job_skillset: job_skillset,
          user_email: user_email,
          token: token,
          substituted_id: substituted_id
        })
        |> case do
          {:ok, _result} ->
            send_resp(conn, 200, Jason.encode!(%{message: "SUCCESS"}))

          {:error, _operation, changeset, _changes} ->
            # Rollback Qdrant changes
            RepoProxy.delete_job_from_qdrant(substituted_id, token)

            ErrorUtils.send_errors(conn, changeset)
        end

      _ ->
        send_resp(conn, 400, Jason.encode!(%{errors: "PAYLOAD_MALFORMED"}))
    end
  end
end
