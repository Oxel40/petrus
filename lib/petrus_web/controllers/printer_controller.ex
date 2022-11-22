defmodule PetrusWeb.PrinterController do
  use PetrusWeb, :controller

  defp render_print(conn) do
    conn
    |> assign(:page_header, "Skriv Ut")
    |> render("index.html")
  end

  defp render_status(conn) do
    conn
    |> assign(:page_header, "Skrivar Status")
    |> render("status.html")
  end

  def show(conn, _params) do
    render_print(conn)
  end

  def post(conn, %{"print_form" => %{"file" => %Plug.Upload{:content_type => "application/pdf",
                                                            :path => path,
                                                            :filename => filename}}})
  do
    {_, 0} = System.cmd("lp", [path])
    conn
    |> put_flash(:info, filename <> " sent for printing")
    |> render_print()
  end

  def post(conn, _params) do
    conn
    |> put_flash(:error, "Invalid print request")
    |> render_print()
  end

  def status(conn, _params) do
    {printer_log, 0} = System.cmd("lpstat", ["-t"])
    conn
    |> assign(:printer_log, printer_log)
    |> render_status()
  end

  def clear_print_queue(conn, _params) do
    {_, 0} = System.cmd("cancel", ["-a"])
    {printer_log, 0} = System.cmd("lpstat", ["-t"])
    conn
    |> assign(:printer_log, printer_log)
    |> put_flash(:info, "Skrivarkön ränsad")
    |> render_status()
  end
end
