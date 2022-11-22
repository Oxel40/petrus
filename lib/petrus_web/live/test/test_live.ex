defmodule PetrusWeb.TestLive do
  use PetrusWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> allow_upload(:document, accept: ~w(.pdf), max_entries: 1)
     |> allow_upload(:avatar, accept: ~w(.jpg .gif .png), max_entries: 1)}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    PetrusWeb.PrintView.render("index.html", assigns)
  end

  @impl Phoenix.LiveView
  def handle_event("print", _value, socket) do
    IO.puts("print event")

    uploaded_files =
      consume_uploaded_entries(socket, :document, fn %{path: path}, _entry ->
        IO.puts("file path: " <> path)

        dest = Path.join([".", "priv", "static", "uploads", Path.basename(path) <> ".pdf"])

        IO.puts(dest)

        File.cp!(path, dest)
        {:ok, Routes.static_path(socket, "/uploads/#{Path.basename(dest)}")}
      end)

    {:noreply, update(socket, :uploaded_files, &(&1 ++ uploaded_files))}
  end

  @impl Phoenix.LiveView
  def handle_event("show", _value, socket) do
    IO.puts("show event")
    {:noreply, assign(socket, :test, "Test!")}
  end
end
