#!/usr/bin/env sh
set -e

# apply migrations and exec CMD
bin/migrate && exec "$@"