defmodule JobService.JobSkillset do
  use Ecto.Schema
  import Ecto.Changeset
  import JobService.ValidationUtils

  @primary_key false
  schema "job_skillsets" do
    field(:job_id, :integer)
    field(:user_email, :string)
    embeds_many(:skillset, JobService.Skill)
    timestamps()
  end

  def changeset(job_skillset, attrs) do
    job_skillset
    |> cast(attrs, [:job_id, :user_email])
    |> validate_required([:job_id, :user_email])
    |> validate_number(:job_id, greater_than: 0, message: "NEGATIVE_ID")
    |> cast_embed(:skillset)
    |> validate_datatypes([{:job_id, "NOT_NUMBER"}])
  end
end
