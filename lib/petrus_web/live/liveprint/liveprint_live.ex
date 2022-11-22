defmodule PetrusWeb.LiveprintLive do
  use PetrusWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> allow_upload(:document, accept: ~w(.pdf), max_entries: 1)
    }
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    PetrusWeb.LiveprintView.render("index.html", assigns)
  end

  @impl Phoenix.LiveView
  def handle_event("validate", values, socket) do
    IO.puts("validate event")
    _pages = values["printopts"]["pages"]

    {:noreply, socket}
  end
  
  @impl Phoenix.LiveView
  def handle_event("print", _values, socket) do
    IO.puts("print event")

    printed_files =
      consume_uploaded_entries(socket, :document, fn %{path: path}, _entry ->
        dest = path <> ".pdf"
        File.cp!(path, dest)
        case System.cmd("lp", [dest]) do
          {_, 0} -> {:ok, dest}
          {output, _} -> {:error, output}
        end
      end)

    IO.puts("status:")
    IO.puts(printed_files)

    {:noreply, socket}
  end

end
