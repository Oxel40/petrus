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
        },
        %{
          name: "How to petrus",
          str: "Hur man petrusar",
          href: "/how2petrus"
        }
      ]
    }
    json(conn, fuzzyfile)
  end

end
