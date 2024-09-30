defmodule JobService.Router do
  use Plug.Router

  alias JobService.JobController

  plug(JobService.Plugs.Authorization)
  plug(:match)
  plug(:dispatch)

  post("/skillset", do: JobController.handle_skillset_request(conn))

  get("/favicon.ico", do: send_resp(conn, 204, ""))

  get "/alive" do
    send_resp(conn, 200, "OK")
  end

  get "/ready" do
    if database_ready?() do
      send_resp(conn, 200, "OK")
    else
      send_resp(conn, 503, "DATABASE_UNAVAILABLE")
    end
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end

  @spec database_ready?() :: boolean
  defp database_ready? do
    true
  end
end
