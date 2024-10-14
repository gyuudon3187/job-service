defmodule JobService.JobController do
  alias JobService.{Utils, ErrorUtils, RepoProxy}
  import Plug.Conn

  def handle_skillset_request(conn) do
    params = conn.body_params |> Utils.to_snake_case_keys()

    case params do
      %{"description" => description, "title" => title, "url" => url, "skillset" => skillset} ->
        job = %{description: description}

        job_skillset = %{
          "user_email" => conn.assigns[:email],
          "company" => params["company"],
          "title" => title,
          "description" => description,
          "url" => url,
          "skillset" => skillset,
          "date_applied" => params["date_applied"],
          "deadline" => params["deadline"]
        }

        case RepoProxy.save_job_and_job_skillset(job, job_skillset) do
          {:ok, _result} ->
            send_resp(conn, 201, Jason.encode!(%{message: "SUCCESS"}))

          {:error, _operation, changeset, _changes} ->
            ErrorUtils.send_errors(conn, changeset)
        end

      _ ->
        send_resp(conn, 400, Jason.encode!(%{errors: "PAYLOAD_MALFORMED"}))
    end
  end
end
