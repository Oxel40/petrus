defmodule PetrusWeb.AuthController do
  use PetrusWeb, :controller
  require Logger

  def callback(conn, %{"token" => token}) do
    conn
    |> put_resp_cookie(token_cookie(), token, encrypt: true)
    |> redirect(to: "/")
  end

  def require_auth(conn, _params) do
    if Mix.env() == :prod do
      ### \/\/ TODO: Remove this after datasektionen.se is fixed \/\/ ###
      Logger.alert("Ignoring authenctication")
      conn
      ### /\/\ TODO: Remove this after datasektionen.se is fixed /\/\ ###
    else
      if verified?(conn) do
        conn
      else
        conn
        |> redirect(external: "#{login_authority()}/login?callback=#{callback_url(conn)}")
        |> halt()
      end
    end
  end

  defp verified?(conn) do
    conn = fetch_cookies(conn, encrypted: token_cookie())
    token_name = token_cookie()

    case conn.cookies do
      %{^token_name => token} ->
        verify_token(token)

      _ ->
        false
    end
  end

  defp verify_token(token) do
    {:ok, response} =
      HTTPoison.get("#{login_authority()}/verify/#{token}.json?api_key=TODO")

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

    URI.encode("#{scheme}://#{conn.host}:#{port}/auth/callback")
  end

  defp login_authority() do
    Application.fetch_env!(:petrus, :login_authority)
  end

  defp token_cookie() do
    "petrus-auth-token"
  end
end
