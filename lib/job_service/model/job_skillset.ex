defmodule JobService.JobSkillset do
  use Ecto.Schema
  import Ecto.Changeset
  import JobService.ValidationUtils

  @primary_key false
  schema "job_skillsets" do
    belongs_to(:job, JobService.Job, foreign_key: :job_id)
    field(:user_email, :string)
    field(:url, :string)
    field(:date_applied, :date)
    field(:deadline, :date)
    embeds_many(:skillset, JobService.Skill)
    timestamps()
  end

  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:job_id, :user_email, :url, :date_applied, :deadline])
    |> validate_required([:job_id, :user_email, :url])
    |> validate_format(
      :url,
      ~r/^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w\.\-~]*)*(\?.*)?$/,
      message: "NOT_URL"
    )
    |> cast_embed(:skillset)
    |> validate_datatypes([
      {:job_id, "NOT_NUMBER"},
      {:user_email, "NOT_STRING"},
      {:url, "NOT_STRING"},
      {:date_applied, "NOT_DATE"},
      {:deadline, "NOT_DATE"}
    ])
  end
end
