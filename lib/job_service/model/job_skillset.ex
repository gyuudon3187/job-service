defmodule JobService.JobSkillset do
  use Ecto.Schema
  import Ecto.Changeset
  import JobService.ValidationUtils

  @primary_key false
  schema "job_skillsets" do
    belongs_to(:job, JobService.Job, foreign_key: :job_id)
    field(:user_email, :string)
    field(:company, :string)
    field(:url, :string)
    field(:date_applied, :date)
    field(:deadline, :date)
    embeds_many(:skillset, JobService.Skill)
    timestamps()
  end

  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:job_id, :user_email, :company, :url, :date_applied, :deadline])
    |> validate_required([:job_id, :user_email, :url])
    |> validate_format(
      :url,
      ~r/^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w\.\-~]*)*(\?.*)?$/,
      message: "NOT_URL"
    )
    |> validate_date_order(:date_applied, :deadline)
    |> cast_embed(:skillset)
    |> validate_datatypes([
      {:user_email, "NOT_STRING"},
      {:company, "NOT_STRING"},
      {:url, "NOT_STRING"},
      {:date_applied, "NOT_DATE"},
      {:deadline, "NOT_DATE"}
    ])
  end

  defp validate_date_order(changeset, date_field1, date_field2) do
    date1 = get_field(changeset, date_field1)
    date2 = get_field(changeset, date_field2)

    if date1 && date2 && Date.compare(date1, date2) == :gt do
      add_error(
        changeset,
        date_field2,
        "MUST_BE_AFTER_#{String.upcase(Atom.to_string(date_field1))}"
      )
    else
      changeset
    end
  end
end
