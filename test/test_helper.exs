ExUnit.start()

Code.require_file("router/skillset/utils.exs", __DIR__)

defmodule JobService.Router.TestUtils do
  use Plug.Test
  use ExUnit.Case
  alias JobService.Router

  @opts Router.init([])
  @jwt JobService.JWT.generate_and_sign!()

  def assert_status_and_expected_errors(%{
        conn: conn,
        expected_errors: errors,
        expected_status: status
      }) do
    assert Jason.decode!(conn.resp_body) == %{"errors" => errors}
    assert conn.status == status
  end

  def assert_status_and_expected_errors(%{
        conn: conn,
        expected_message: message,
        expected_status: status
      }) do
    assert Jason.decode!(conn.resp_body) == %{"message" => message}
    assert conn.status == status
  end

  def prepare_test(context, get_payload, get_expected_errors) do
    payload = get_payload.(context)
    expected_errors = get_expected_errors.(context)

    Map.merge(payload, expected_errors)
  end

  def do_test(%{payload: payload}) do
    # Given
    conn = get_conn_with_jwt(payload)

    # When
    conn = Router.call(conn, @opts)

    # Then
    %{expected_message: "SUCCESS", conn: conn}
  end

  def do_test(%{payload: payload, expected_errors: errors}) do
    # Given
    conn = get_conn_with_jwt(payload)

    # When
    conn = Router.call(conn, @opts)

    # Then
    %{expected_errors: errors, conn: conn}
  end

  @spec get_conn_with_jwt(map()) :: Conn.t()
  defp get_conn_with_jwt(payload) do
    conn(:post, "/skillset", payload)
    |> set_jwt_token()
  end

  @spec set_jwt_token(Conn.t()) :: Conn.t()
  defp set_jwt_token(conn) do
    put_req_header(conn, "authorization", "Bearer " <> @jwt)
  end
end
