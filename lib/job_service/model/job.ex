defmodule JobService.Job do
  use Ecto.Schema
  import Ecto.Changeset
  import JobService.ValidationUtils

  @primary_key false
  schema "jobs" do
    field(:description, :string)
    timestamps()
  end

  def changeset(job, attrs) do
    job
    |> cast(attrs, [:description])
    |> validate_required([:description])
    |> validate_datatypes([{:description, "NOT_STRING"}])
  end
end
