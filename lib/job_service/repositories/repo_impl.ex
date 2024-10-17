defmodule JobService.RepoImpl do
  alias JobService.Repo
  alias JobService.{Job, JobSkillset}
  alias HTTPoison.Response
  alias Ecto.Multi
  import Ecto.Query
  import JobService.QdrantUtils

  def delete_job_from_qdrant(id, token) do
    endpoint = "delete_embedding"

    post_json_to_qdrant(endpoint, %{id: id}, token)
    |> case do
      {:ok, %HTTPoison.Response{status_code: status}} ->
        if status != 200 do
          {:error, "EMBEDDING_DELETION_FAILED_WITH_STATUS_#{status}"}
        else
          {:ok, nil}
        end

      _ ->
        {:error, "EMBEDDING_DELETION_FAILED"}
    end
  end

  def upsert_job_and_job_skillset(context)

  def upsert_job_and_job_skillset(context) do
    Multi.new()
    |> upsert_job_as_embedding_into_or_retrieve_similar_job_from_qdrant(context)
    |> upsert_job_skillset_into_postgres_and_with_updated_id_if_similar_job_was_detected(context)
    |> cleanup_job_and_job_skillset_if_upserted_job_is_substitution_for_another_job(context)
    |> Repo.transaction()
  end

  defp upsert_job_as_embedding_into_or_retrieve_similar_job_from_qdrant(multi, %{
         job: job,
         token: token
       }) do
    multi
    |> Multi.run(:job, fn _repo, _changes ->
      if Job.changeset(job).valid? do
        endpoint = "embed"

        case post_json_to_qdrant(endpoint, job, token) do
          {:ok, %Response{body: context, status_code: 200}} ->
            {:ok, Jason.decode!(context)}

          {:ok, %Response{body: context, status_code: 201}} ->
            IO.inspect(context)
            {:ok, :job_upserted}

          {_, %Response{body: reason}} ->
            {:error, Jason.decode!(reason)}
        end
      else
        {:error, "INVALID_JOB"}
      end
    end)
  end

  defp upsert_job_skillset_into_postgres_and_with_updated_id_if_similar_job_was_detected(
         multi,
         %{job_skillset: job_skillset}
       ) do
    multi
    |> Multi.run(:job_skillset, fn
      repo, %{job: %{"id" => id, "description" => _description}} ->
        %{job_skillset | "job_id" => id}
        |> upsert_job_skillset_into_postgres(repo)

      repo, %{job: :job_upserted} ->
        job_skillset
        |> upsert_job_skillset_into_postgres(repo)

      _repo, _unexpected ->
        {:error, "UNEXPECTED_RESPONSE"}
    end)
  end

  defp cleanup_job_and_job_skillset_if_upserted_job_is_substitution_for_another_job(
         multi,
         %{substituted_id: substituted_id} = context
       ) do
    multi
    |> Multi.run(:cleanup, fn repo, _changes ->
      if substituted_id != nil do
        cleanup_job_and_job_skillset(context, repo)
      else
        {:ok, nil}
      end
    end)
  end

  defp upsert_job_skillset_into_postgres(job_skillset, repo) do
    job_skillset
    |> JobSkillset.changeset()
    |> repo.insert(
      on_conflict: {:replace_all_except, [:inserted_at]},
      conflict_target: [:job_id, :user_email]
    )
  end

  defp cleanup_job_and_job_skillset(context, repo) do
    aggregate_job_skillsets_with_id(context, repo)
    |> case do
      1 ->
        delete_substituted_job_skillset(context, repo)
        |> case do
          {1, nil} ->
            delete_substituted_job(context)

          _ ->
            {:error, "CANNOT_DELETE_JOB_SKILLSET"}
        end

      _ ->
        {:ok, "NO_DELETION_NEEDED"}
    end
  end

  defp aggregate_job_skillsets_with_id(%{substituted_id: substituted_id}, repo) do
    query =
      from(js in JobSkillset,
        where: js.job_id == ^substituted_id
      )

    repo.aggregate(query, :count, :job_id)
  end

  defp delete_substituted_job_skillset(
         %{substituted_id: substituted_id, user_email: user_email},
         repo
       ) do
    delete_query =
      from(js in JobSkillset,
        where: js.job_id == ^substituted_id and js.user_email == ^user_email
      )

    repo.delete_all(delete_query)
  end

  defp delete_substituted_job(%{substituted_id: substituted_id, token: token}) do
    delete_job_from_qdrant(substituted_id, token)
  end
end
