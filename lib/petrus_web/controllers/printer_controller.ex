defmodule PetrusWeb.PrinterController do
  use PetrusWeb, :controller
  alias Petrus.PrinterBroker, as: PB

  defp render_print(conn) do
    conn
    |> assign(:page_header, "Skriv Ut")
    |> render("index.html")
  end

  defp render_status(conn) do
    {_, printer_log} = PB.agent_status()

    conn
    |> assign(:printer_log, printer_log)
    |> assign(:page_header, "Skrivar Status")
    |> render("status.html")
  end

  def print(conn, _params) do
    # ... skrivare inte tillgänglig
    render_print(conn)
  end

  def status(conn, _params) do
    # {printer_log, 0} = System.cmd("lpstat", ["-t"])
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
      _ -> put_flash(conn, :info, filename <> " sent for printing")
    end
    |> render_print()

    # {_, 0} = System.cmd("lp", [path])
    # conn
    # |> put_flash(:info, filename <> " sent for printing")
    # |> render_print()
  end

  def post(conn, _params) do
    conn
    |> put_flash(:error, "Invalid print request")
    |> render_print()
  end

  def clear_print_queue(conn, _params) do
    PB.clear_queue()

    conn
    |> put_flash(:info, "Skrivarkön ränsad")
    |> render_status()
  end
end
