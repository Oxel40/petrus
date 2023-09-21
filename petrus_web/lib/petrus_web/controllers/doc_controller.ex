defmodule PetrusWeb.DocController do
  use PetrusWeb, :controller

  def doc(conn, _params) do
    conn
    |> render("index.html")
  end
end
