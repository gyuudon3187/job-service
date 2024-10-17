defmodule JobService.QdrantUtils do
  import JobService.HttpUtils

  @qdrant_base_url "http://localhost:5000"
  @json_header [
    {"Content-type", "application/json"}
  ]

  def post_json_to_qdrant(endpoint, payload, token),
    do: post_to_qdrant(endpoint, payload, @json_header, token)

  def post_to_qdrant(endpoint, payload, headers_without_auth, token) do
    HTTPoison.post(
      "#{@qdrant_base_url}/#{endpoint}",
      Jason.encode!(payload),
      get_headers_with_auth(headers_without_auth, token)
    )
  end
end
