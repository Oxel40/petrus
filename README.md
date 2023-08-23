# Petrus
This is the system for simpler interaction with the printer *Petrus*, situated
in the storage in META. It's a web based system where the user can upload e.g.
PDF for printing, without connecting to, installing and configuring the printer
on their own machine. The system consists of two components, the website
(`petrus_web`) and the agent (`petrus_agent`).

## petrus_web
This is the central connecting part of the system, the user interacts with the
website in order to send print requests to the agent. The agent is connected to
the web-server through a websocket connection, receiving print requests and
pushing status updates displayed on the website.

## petrus_agent
The agent is a program running on a client connected to the printer (e.g. a
raspberry pi). The agent connects with the web-server using a websocket
connection to receive print requests and to push status information. The
program in interacts with the printer over the local network using the CUPS
system by utilizing the `lp` set of commands exposed by CUPS.
