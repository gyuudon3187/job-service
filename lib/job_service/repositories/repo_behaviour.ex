defmodule JobService.RepoBehaviour do
  alias Ecto.{Changeset, Schema}

  @callback save_job_skillset(map()) :: {:ok, Schema.t()} | {:error, Changeset.t()}
end
