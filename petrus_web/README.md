# Petrus

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
