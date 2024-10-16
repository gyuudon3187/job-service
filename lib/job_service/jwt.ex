defmodule JobService.JWT do
  use Joken.Config

  @impl true
  def token_config do
    %{}
    |> add_claim("email", fn -> "user@example.com" end, &validate_email/1)
  end

  def get_dummy_token(email) do
    config = add_claim(%{}, "email", fn -> email end, &validate_email/1)

    {:ok, token, _claims} = Joken.generate_and_sign(config)
    token
  end

  @spec validate_email(String.t()) :: boolean
  defp validate_email(email) when is_binary(email) do
    regex = ~r/^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/
    Regex.match?(regex, email)
  end
end
