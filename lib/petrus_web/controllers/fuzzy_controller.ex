defmodule PetrusWeb.FuzzyController do
  use PetrusWeb, :controller

  def fuzzyfile(conn, _params) do
    fuzzyfile = %{
      "@type": "fuzzyfile",

      fuzzes: [
        %{
          name: "Skriv Ut",
          str: "skriv ut",
          href: "/print"
        },
        %{
          name: "Skrivar Status",
          str: "skrivar status",
          href: "/status"
        }
      ]
    }
    json(conn, fuzzyfile)
  end

end
