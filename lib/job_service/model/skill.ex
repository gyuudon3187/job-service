defmodule JobService.Skill do
  use Ecto.Schema
  import Ecto.Changeset
  import JobService.ValidationUtils

  @skill_types [
    "technical",
    "problem_solving",
    "communication",
    "project_management",
    "security",
    "teamwork",
    "adaptability",
    "customer_focus"
  ]

  embedded_schema do
    field(:topic, :string)
    field(:importance, :integer)
    field(:type, :string)
    field(:content, :string)
  end

  def changeset(skill, attrs) do
    skill
    |> cast(attrs, [:topic, :importance, :type, :content])
    |> validate_required([:topic, :importance, :type])
    |> validate_length(:topic, min: 2, message: "TOO_SHORT")
    |> validate_inclusion(:importance, Enum.to_list(1..10), message: "EXCEEDS_BOUNDS")
    |> validate_inclusion(:type, @skill_types)
    |> validate_datatypes([
      {:topic, "NOT_STRING"},
      {:importance, "NOT_NUMBER"},
      {:type, "NOT_TYPE"},
      {:content, "NOT_STRING"}
    ])
  end
end
