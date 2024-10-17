defmodule JobService.RepoBehaviour do
  @callback delete_job_from_qdrant(String.t(), String.t()) :: {:ok, nil} | {:error, String.t()}
  @callback upsert_job_and_job_skillset(map()) ::
              {:ok, %{optional(any) => any}}
              | {:error, any, any, %{optional(any) => any}}
end
