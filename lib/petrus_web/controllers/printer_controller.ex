defmodule PetrusWeb.PrinterController do
  use PetrusWeb, :controller
  alias Petrus.PrinterBroker, as: PB

  defp render_print(conn) do
    {code, _} = PB.agent_status()

    if code == :error do 
      put_flash(conn, :error, "Ingen skrivare tillgänglig")
    else
      conn
    end
    |> assign(:page_header, "Skriv Ut")
    |> render("index.html")
  end

  defp render_status(conn) do
    {code, printer_log} = PB.agent_status()

    if code == :error do 
      put_flash(conn, :error, "Ingen skrivare tillgänglig")
    else
      conn
    end
    |> assign(:printer_log, printer_log)
    |> assign(:page_header, "Skrivar Status")
    |> render("status.html")
  end

  def print(conn, _params) do
    render_print(conn)
  end

  def status(conn, _params) do
    {_, printer_log} = PB.agent_status()

    conn
    |> assign(:printer_log, printer_log)
    |> render_status()
  end

  def post(conn, %{
        "print_form" => %{
          "file" => %Plug.Upload{
            :content_type => "application/pdf",
            :path => path,
            :filename => filename
          }
        }
      }) do
    {code, msg} = PB.print_binary(File.read!(path))

    case code do
      :error -> put_flash(conn, :error, msg)
      _ -> put_flash(conn, :info, "\"#{filename}\" skickad för utskrift")
    end
    |> render_print()
  end

  def post(conn, _params) do
    conn
    |> put_flash(:error, "Felaktig utskrifts begäran (Invalid request)")
    |> render_print()
  end

  def clear_print_queue(conn, _params) do
    PB.clear_queue()

    conn
    |> put_flash(:info, "Skrivarkön ränsad")
    |> render_status()
  end
end
