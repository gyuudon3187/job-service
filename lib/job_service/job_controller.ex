defmodule JobService.JobController do
  import Plug.Conn

  @type error :: {:error, String.t()}

  def handle_skillset_request(conn) do
    case conn.body_params do
      %{"jobId" => job_id, "skillset" => _skillset} ->
        with :ok <- validate_job_id(job_id) do
          send_resp(conn, 200, Jason.encode!(%{"message" => "SUCCESS"}))
        end

      _ ->
        send_resp(conn, 400, "Something went wrong")
    end
  end

  @spec validate_job_id(integer) :: :ok | error
  defp validate_job_id(job_id) do
    if job_id > 0 do
      :ok
    else
      {:error, "NEGATIVE_ID"}
    end
  end
end
