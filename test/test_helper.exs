ExUnit.start()

Mox.defmock(JobService.MockRepo, for: JobService.RepoBehaviour)
Application.put_env(:job_service, :repo_impl, JobService.MockRepo)
Code.require_file("router/skillset/utils.exs", __DIR__)

defmodule JobService.Router.TestUtils do
  @moduledoc """
  Defines helper functions that can be imported by any test module.
  """

  use Plug.Test
  use ExUnit.Case
  alias JobService.{Router, JWT}

  @opts Router.init([])

  @doc """
  Asserts, in order, that:

  1) The response body equals the expected errors.
  2) The response status code equals the expected status code.
  """
  @spec assert_expected_errors_and_status(%{
          conn: Plug.Conn.t(),
          expected_errors: map() | String.t(),
          expected_status: integer()
        }) :: :ok
  def assert_expected_errors_and_status(%{
        conn: conn,
        expected_errors: errors,
        expected_status: status
      }) do
    assert Jason.decode!(conn.resp_body) == %{"errors" => errors}
    assert conn.status == status
  end

  @doc """
  Asserts, in order, that:

  1) The response body equals the expected message.
  2) The response status code equals the expected status code.
  """
  @spec assert_expected_errors_and_status(%{
          conn: Plug.Conn.t(),
          expected_errors: map() | String.t(),
          expected_status: integer()
        }) :: :ok
  def assert_message_and_status(%{
        conn: conn,
        expected_message: message,
        expected_status: status
      }) do
    assert Jason.decode!(conn.resp_body) == %{"message" => message}
    assert conn.status == status
  end

  @doc """
  Takes an ExUnit context and two functions.
  The context is passed to the functions for retrieving: 

  - the payload to be sent to the given endpoint
  - the errors expected from calling the endpoint with that payload.

  Returns the payload and errors as a map by merging the two.
  """
  @spec prepare_test(map(), fun(), fun()) :: map()
  def prepare_test(context, get_payload, get_expected_errors) do
    payload = get_payload.(context)
    expected_errors = get_expected_errors.(context)

    Map.merge(payload, expected_errors)
  end

  @doc """
  Executes a valid (or invalid if expected_errors are provided)
  test after having prepared the payload.
  """
  @spec do_test(%{payload: map()}) ::
          %{expected_message: :SUCCESS, conn: Plug.Conn.t()}
          | %{expected_errors: map(), conn: Plug.Conn.t()}
  def do_test(%{expected_errors: errors} = context) do
    # Given
    conn = get_conn_with_jwt(context)

    # When
    conn = Router.call(conn, @opts)

    # Then
    %{expected_errors: errors, conn: conn}
  end

  def do_test(context) do
    # Given
    conn = get_conn_with_jwt(context)

    # When
    conn = Router.call(conn, @opts)

    # Then
    %{expected_message: "SUCCESS", conn: conn}
  end

  @spec get_conn_with_jwt(map()) :: Conn.t()
  defp get_conn_with_jwt(%{payload: payload} = context) do
    conn(:post, "/skillset", payload)
    |> set_jwt_token(context)
  end

  @spec set_jwt_token(Conn.t(), map()) :: Conn.t()
  defp set_jwt_token(conn, %{invalid_email: email}) do
    token = JWT.get_dummy_token(email)
    put_req_header(conn, "authorization", "Bearer " <> token)
  end

  defp set_jwt_token(conn, _) do
    put_req_header(conn, "authorization", "Bearer " <> JWT.generate_and_sign!())
  end
end
