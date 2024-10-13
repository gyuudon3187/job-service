defmodule JobService.Job do
  use Ecto.Schema
  import Ecto.Changeset
  import JobService.ValidationUtils

  schema "jobs" do
    field(:description, :string)
    has_many(:job_skillset, JobService.JobSkillset)
    timestamps()
  end

  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:description])
    |> validate_required([:description])
    |> validate_datatypes([{:description, "NOT_STRING"}])
  end
end
