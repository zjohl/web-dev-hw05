#!/bin/bash

export MIX_ENV=prod
export PORT=4792

echo "Stopping old copy of app, if any..."

_build/prod/rel/memory/bin/memory stop || true

echo "Starting app..."

# TODO: You want start.

_build/prod/rel/memory/bin/memory start

# TODO: Add a cron rule or systemd service file
#       to start your app on system boot.

