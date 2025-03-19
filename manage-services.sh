#!/usr/bin/env bash
set -e

# Define the operation to perform (start, stop, pull, down, etc.)
OPERATION="$*"

if [ -z "$OPERATION" ]; then
  echo "Usage: $0 <operation> [directory]"
  echo "  operation: start, stop, pull, down, etc."
  exit 1
fi

# Find all directories containing compose.yml file
COMPOSE_DIRS=$(find . -name "compose.yml" | sort | xargs dirname)

# Separate the special service from other services
SPECIAL_SERVICE="./tsd-proxy"
SERVICES=""

for DIR in $COMPOSE_DIRS; do
  if [[ "$DIR" != *"$SPECIAL_SERVICE"* ]]; then
    SERVICES="$SERVICES $DIR"
  fi
done

if [ -z "$SERVICES" ]; then
  echo "No compose files found"
  exit 1
fi

echo "Found compose files in the following directories:"
echo "$SERVICES"
echo ""

# Execute the operation on each compose file
for DIR in $SERVICES; do
  CMD="podman-compose $OPERATION"
  echo "Executing '$CMD' in $DIR"
  (cd "$DIR" && $CMD)
done

echo "All operations completed"
