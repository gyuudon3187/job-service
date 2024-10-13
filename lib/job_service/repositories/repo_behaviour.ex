defmodule JobService.RepoBehaviour do
  @callback save_job_and_job_skillset(map(), map()) ::
              {:ok, %{optional(any) => any}}
              | {:error, any, any, %{optional(any) => any}}
end
