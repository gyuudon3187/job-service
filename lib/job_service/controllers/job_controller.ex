defmodule JobService.JobController do
  import Plug.Conn
  alias JobService.{JobSkillset, JobSkillsetErrors}

  def handle_skillset_request(conn) do
    case conn.body_params do
      %{"jobId" => job_id, "skillset" => skillset} ->
        skillset = JobSkillset.add_skillset_ids(skillset)

        JobSkillset.validate_job_skillset(job_id, skillset)
        |> JobSkillsetErrors.reconstruct_errors_as_job_skillset()
        |> send_resp_depending_on_errors(conn)

      _ ->
        send_resp(conn, 400, "PAYLOAD_MALFORMED")
    end
  end

  @spec send_resp_depending_on_errors(JobSkillsetErrors.t(), Plug.Conn.t()) :: Plug.Conn.t()
  defp send_resp_depending_on_errors(errors, conn) do
    case errors do
      %{job_id: nil, skillset: []} ->
        send_resp(conn, 200, Jason.encode!(%{"message" => "SUCCESS"}))

      _ ->
        send_resp(conn, 422, Jason.encode!(%{"errors" => errors}))
    end
  end
end
