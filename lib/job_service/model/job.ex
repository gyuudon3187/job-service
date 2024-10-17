defmodule JobService.Job do
  use Ecto.Schema
  import Ecto.Changeset
  import JobService.ValidationUtils

  @primary_key {:id, :string, autogenerate: false}
  schema "jobs" do
    field(:description, :string)
    # has_many(:job_skillset, JobService.JobSkillset)
    timestamps()
  end

  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:id, :description])
    |> validate_required([:id, :description])
    |> validate_datatypes([{:description, "NOT_STRING"}])
  end
end
