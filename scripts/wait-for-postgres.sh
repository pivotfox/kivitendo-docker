#!/bin/bash
set -e

host="$1"
shift
cmd="$@"

until timeout 1 bash -c "/dev/tcp/${host}:5432 >/dev/null 2>&1"; do
  >&2 echo "PostgreSQL is unavailable - sleeping"
  sleep 1
done

>&2 echo "PostgreSQL is up - executing command"
exec "$cmd"
