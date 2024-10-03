defmodule JobService.Repo do
  use Ecto.Repo,
    otp_app: :job_service,
    adapter: Ecto.Adapters.Postgres
end
