defmodule JobService.JobController do
  import Plug.Conn

  def handle_skillset_request(conn) do
    case get_auth_email(conn) do
      {:ok, _email} ->
        send_resp(conn, 200, Jason.encode!(%{"message" => "SUCCESS"}))

      _ ->
        send_resp(conn, 400, "Something went wrong")
    end
  end

  defp get_auth_email(_conn) do
    {:ok, "test@test.com"}
  end
end
