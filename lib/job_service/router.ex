defmodule JobService.Router do
  use Plug.Router

  alias JobService.JobController

  plug(:match)
  plug(:dispatch)

  post("/skillset", do: JobController.handle_skillset_request(conn))

  get "/favicon.ico" do
    # Respond with no content
    send_resp(conn, 204, "")
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
