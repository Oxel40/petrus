# PetrusWeb

This is the web frontend for the printing system.

## Running locally
To run locally you need to have elixir installed. Then you fetch all 
dependencies by running `mix deps.get`, and to start the server you run 
`mix phx.server`. The local server should be accessible on
[`localhost:4000`](http://localhost:4000).

## Deployment
This site is currently designed to be deployed to fly.io using docker. If you 
have `flyctl` installed it's just to run something like `flyctl deploy` (or 
`flyctl launch` if you need to create a new fly.io application).

There are some environment variables that need to be set in order for the 
deployed application to work correctly (not needed if running debug locally):

- `PHX_HOST`: The host name of the server, e.g. `petrus.datasektionen.se`
- `PORT`: The port to run the webserver on
- `SECRET_KEY_BASE`: Used internally by the phoenix framework, can be generated
by `mix phx.gen.secret`
- `AGENT_SECRET`: The printer agent secret, only known to this webserver and 
the printer agent
