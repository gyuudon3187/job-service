defmodule JobService.JobSkillset do
  use Ecto.Schema
  import Ecto.Changeset
  alias JobService.JobSkillsetErrors

  @skill_types [
    :technical,
    :problem_solving,
    :communication,
    :project_management,
    :security,
    :teamwork,
    :adaptability,
    :customer_focus
  ]

  @type skill_type ::
          unquote(
            @skill_types
            |> Enum.map(&inspect/1)
            |> Enum.join(" | ")
            |> Code.string_to_quoted!()
          )

  @type skill :: %{
          id: integer(),
          topic: String.t(),
          importance: integer(),
          type: skill_type(),
          content: String.t() | nil
        }

  @type skillset :: list(skill())

  @type t :: %__MODULE__{
          job_id: integer(),
          skillset: skillset()
        }

  schema "job_skillset" do
    field(:job_id, :integer)
    field(:skillset, {:array, :map})
    timestamps()
  end

  def changeset(job_skill, attrs) do
    job_skill
    |> cast(attrs, [:job_id, :user_email, :skillset])
    |> validate_required([:job_id, :user_email, :skillset])
  end

  def add_skillset_ids(skillset) do
    skillset
    |> Enum.with_index(1)
    |> Enum.map(fn {skill, index} -> Map.put(skill, "id", index) end)
  end

  @moduledoc """
  Validates the given job ID and skillset.

  Returns a list of errors.

  ## Examples

      iex> JobService.JobSkillset.validate_job_skillset(1, [%{"id" => 1, "topic" => "Experience in serverless architecture and AWS", "importance" => 9, "type" => "technical", "content" => "Some text"}, %{"id" => 2, "topic" => "Working in an agile environment with Scrum or Kanban", "importance" => 7, "type" => "project management", "content" => "Some text"}])
      [
        :ok,
        [:ok, :ok, :ok, :ok],
        [:ok, :ok, {:error, :skill_type, "NOT_SKILL_TYPE", 2}, :ok]
      ]
  """
  @spec validate_job_skillset(integer(), skillset()) ::
          list(JobSkillsetErrors.error())
  def validate_job_skillset(job_id, skillset) do
    [validate_job_id(job_id) | validate_skillset(skillset)]
  end

  @spec validate_job_id(integer()) :: :ok | JobSkillsetErrors.error()
  defp validate_job_id(job_id) when is_number(job_id) do
    if job_id > 0 do
      :ok
    else
      {:error, :job_id, "NEGATIVE_ID"}
    end
  end

  defp validate_job_id(_job_id) do
    {:error, :job_id, "NOT_NUMBER"}
  end

  @spec validate_skillset(skillset()) :: list(:ok | JobSkillsetErrors.error())
  defp validate_skillset(skillset) when is_list(skillset) do
    Enum.map(skillset, fn skill -> validate_skill(skill) end)
  end

  defp validate_skillset(_skillset) do
    {:error, :skillset, "NOT_LIST"}
  end

  @spec validate_skill(skill()) :: list(%{String.t() => String.t()})
  defp validate_skill(skill) do
    validators_with_args = [
      {&validate_topic/2, skill["topic"]},
      {&validate_importance/2, skill["importance"]},
      {&validate_type/2, skill["type"]},
      {&validate_content/2, skill["content"]}
    ]

    Enum.map(validators_with_args, fn {validator, arg} ->
      validator.(arg, skill["id"])
    end)
  end

  @spec validate_topic(String.t(), integer()) :: :ok | JobSkillsetErrors.error_skill()
  defp validate_topic(topic, id) when is_binary(topic) do
    if String.length(topic) < 2 do
      {:error, :topic, "TOO_SHORT", id}
    else
      :ok
    end
  end

  defp validate_topic(_topic, id) do
    {:error, :topic, "NOT_STRING", id}
  end

  @spec validate_importance(integer(), integer()) :: :ok | JobSkillsetErrors.error_skill()
  defp validate_importance(importance, id) when is_number(importance) do
    if importance in 1..10 do
      :ok
    else
      {:error, :importance, "EXCEEDS_BOUNDS", id}
    end
  end

  defp validate_importance(_importance, id) do
    {:error, :importance, "NOT_NUMBER", id}
  end

  @spec validate_type(String.t(), integer()) :: :ok | JobSkillsetErrors.error_skill()
  defp validate_type(type, id) do
    if is_skill_type?(type) do
      :ok
    else
      {:error, :skill_type, "NOT_SKILL_TYPE", id}
    end
  end

  @spec validate_content(String.t(), integer()) :: :ok | JobSkillsetErrors.error_skill()
  defp validate_content(content, id) do
    case content do
      binary when is_binary(binary) -> :ok
      nil -> :ok
      _ -> {:error, :content, "NOT_STRING", id}
    end
  end

  @spec is_skill_type?(String.t()) :: boolean()
  defp is_skill_type?(type) do
    String.to_atom(type) in @skill_types
  end
end

defmodule JobService.JobSkillsetErrors do
  @type skill :: %{
          id: integer() | nil,
          topic: String.t() | nil,
          importance: String.t() | nil,
          type: String.t() | nil,
          content: String.t() | nil
        }

  @type skillset :: list(skill())

  @type t :: %__MODULE__{
          job_id: String.t() | nil,
          skillset: skillset()
        }

  @type error_name :: :job_id | :topic | :importance | :content | :skill_type
  @type error :: {:error, error_name(), String.t()}
  @type error_skill :: {:error, error_name(), String.t(), integer()}

  @derive {Jason.Encoder, only: [:job_id, :skillset]}
  defstruct job_id: nil, skillset: []

  @moduledoc """
  Returns a map with the same structure as JobService.JobSkillset.t(),
  but with the fields set to the corresponding errors received as argument.

  ## Examples

      iex> JobService.JobSkillsetErrors.reconstruct_errors_as_job_skillset([{:error, :job_id, "NOT_NUMBER"}, [{:error, :importance, "EXCEEDS_BOUNDS", 1}, {:error, :skill_type, "NOT_SKILL_TYPE", 1}]])
      %JobService.JobSkillsetErrors{
        job_id: "NOT_NUMBER",
        skillset: [
          %{id: 1, skill_type: "NOT_SKILL_TYPE", importance: "EXCEEDS_BOUNDS"}
        ]
      }
  """
  @spec reconstruct_errors_as_job_skillset(list(:ok | error() | list(error()))) :: t()
  def reconstruct_errors_as_job_skillset(maybe_errors) do
    reconstruct_errors_as_job_skillset(%__MODULE__{job_id: nil, skillset: []}, maybe_errors)
  end

  @spec reconstruct_errors_as_job_skillset(map(), list(:ok | error() | list(error()))) :: t()
  defp reconstruct_errors_as_job_skillset(errors, []), do: errors

  defp reconstruct_errors_as_job_skillset(errors, [:ok | maybe_errors]) do
    reconstruct_errors_as_job_skillset(errors, maybe_errors)
  end

  defp reconstruct_errors_as_job_skillset(errors, [[] | maybe_errors]) do
    reconstruct_errors_as_job_skillset(errors, maybe_errors)
  end

  defp reconstruct_errors_as_job_skillset(errors, [{:error, error_name, msg} | maybe_errors])
       when error_name == :job_id do
    updated_errors = Map.put(errors, error_name, msg)
    reconstruct_errors_as_job_skillset(updated_errors, maybe_errors)
  end

  defp reconstruct_errors_as_job_skillset(errors, [skill_errors | maybe_errors])
       when is_list(skill_errors) do
    # We know this is a list of `error()` for `skill()`, so we build the skill map

    skill_errors = Enum.filter(skill_errors, fn skill_error -> skill_error != :ok end)

    case have_same_skill_id?(skill_errors) do
      :error ->
        {:error, "INCONGRUENT_SKILL_ID"}

      :empty ->
        reconstruct_errors_as_job_skillset(errors, maybe_errors)

      id ->
        Enum.reduce(skill_errors, %{}, fn {:error, error_name, msg, _id}, acc ->
          Map.put(acc, error_name, msg)
        end)
        |> Map.put(:id, id)
        |> update_skillset(errors)
        |> reconstruct_errors_as_job_skillset(maybe_errors)
    end
  end

  @spec have_same_skill_id?(list(error())) :: integer() | :error | :empty
  defp have_same_skill_id?([{_, _, _, first_id} | skill_errors]) do
    Enum.reduce_while(skill_errors, first_id, fn
      {_, _, _, ^first_id}, acc -> {:cont, acc}
      {_, _, _, _}, _acc -> {:halt, :error}
    end)
  end

  defp have_same_skill_id?([]), do: :empty

  @spec update_skillset(skill(), t()) :: t()
  defp update_skillset(skill, %__MODULE__{skillset: skillset} = errors) do
    updated_skillset = [skill | skillset]
    %__MODULE__{errors | skillset: updated_skillset}
  end
end
