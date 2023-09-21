defmodule PetrusWeb.AuthController do
  use PetrusWeb, :controller
  require Logger

  def callback(conn, %{"token" => token}) do
    conn
    |> put_resp_cookie("petrus-auth-token", token, encrypt: true)
    |> redirect(to: "/")
  end

  def require_auth(conn, _params) do
    if verified?(conn) do
      Logger.alert("logged in")
      conn
    else
      Logger.alert("not logged in")
      Logger.alert("callback: #{callback_url(conn)}")

      conn
      |> redirect(external: "#{login_domain()}/login?callback=#{callback_url(conn)}")
      |> halt()
    end
  end

  defp verified?(conn) do
    conn = fetch_cookies(conn, encrypted: ~w(petrus-auth-token))
    case conn.cookies do
      %{"petrus-auth-token" => token} ->
        verify_token(token)
      _ ->
        false
    end
  end

  defp verify_token(token) do
    {:ok, response} =
      HTTPoison.get("#{login_domain()}/verify/#{token}.json?api_key=TODO")

    case response do
      %{status_code: 200} ->
        true

      _ ->
        false
    end
  end

  defp callback_url(conn) do
    scheme =
      case get_req_header(conn, "x-forwarded-proto") do
        [scheme] -> scheme
        [] -> conn.scheme
      end

    port =
      case get_req_header(conn, "x-forwarded-port") do
        [port] -> port
        [] -> conn.port
      end

    # URI.encode("#{scheme}://#{conn.host}:#{port}#{conn.request_path}?#{conn.query_string}")
    URI.encode("#{scheme}://#{conn.host}:#{port}/auth/callback")
  end

  defp login_domain() do
    "http://localhost:1337"
    # "https://login.datasektionen.se"
  end

end
