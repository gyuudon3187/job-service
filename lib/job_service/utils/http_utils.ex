defmodule JobService.HttpUtils do
  def get_headers_with_auth(headers, token), do: [get_auth_header(token) | headers]

  defp get_auth_header(token), do: {"Authorization", "Bearer " <> token}
end
