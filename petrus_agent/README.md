# PetrusAgent

This program runs on a host connected to the printer (most likely by a LAN 
connection). It connects to the web frontend server through a websocket
connection and handles print requests.

## Requirements
- elixir 1.14 or above
- CUPS, with the desired printer being set as the default printer
- a `./secrets` file (only when installing/deploying) with the printer agent 
connection secret in the format of `AGENT_SECRET="super secret key"`

> NOTE: elixir 1.14 isn't available in the raspian package repos. Either you
have to install it from another source, or (which I would recommend) use
Ubunut's raspberry pi compatable image instead.


## Installation/Deployment
Run `install.sh` to build, install and enable the systemd service on the host 
connected to the printer.

## Configuring CUPS
CUPS can either be configured through the terminal or the web-interface,
there exists lots of tutorials and documentation online.
