defmodule JobService.Plugs.Authorization do
  import Plug.Conn
  alias Plug.Conn

  @protected_routes [
    "/skillset"
  ]

  def init(default), do: default

  def call(conn, _opts) do
    if is_protected?(conn) do
      authorize(conn)
    else
      conn
    end
  end

  @spec is_protected?(Conn.t()) :: boolean()
  defp is_protected?(conn) do
    conn.request_path in @protected_routes
  end

  @spec authorize(Conn.t()) :: Conn.t()
  defp authorize(conn) do
    case authorize_user(conn) do
      {:ok, email, token} ->
        conn
        |> assign(:email, email)
        |> assign(:token, token)

      {:error, reason} ->
        conn
        |> send_resp(401, Jason.encode!(%{"errors" => reason}))
        |> halt()
    end
  end

  @spec authorize_user(Conn.t()) :: {:ok, String.t(), String.t()} | {:error, String.t()}
  defp authorize_user(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] -> verify_token(token)
      _ -> {:error, "INVALID_TOKEN"}
    end
  end

  @spec verify_token(String.t()) :: {:ok, String.t(), String.t()} | {:error, String.t()}
  defp verify_token(token) do
    case JobService.JWT.verify_and_validate(token) do
      {:ok, claims} ->
        {:ok, claims["email"], token}

      _ ->
        {:error, "INVALID_TOKEN"}
    end
  end
end
