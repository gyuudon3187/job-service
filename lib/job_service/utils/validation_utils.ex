defmodule JobService.ValidationUtils do
  import Ecto.Changeset

  def validate_datatypes(changeset, fields_and_errs) do
    Enum.reduce(fields_and_errs, changeset, fn {field, custom_err}, acc ->
      case changeset.errors[field] do
        {"is invalid", _} -> replace_default_with_custom_error(acc, field, custom_err)
        _ -> acc
      end
    end)
  end

  defp replace_default_with_custom_error(changeset, field, custom_error) do
    changeset
    |> delete_invalid_error(field)
    |> add_error(field, custom_error)
  end

  defp delete_invalid_error(changeset, field) do
    update_in(changeset.errors, fn errors ->
      Enum.reject(errors, fn {error_field, {message, _}} ->
        error_field == field and message == "is invalid"
      end)
    end)
  end
end
