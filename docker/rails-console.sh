#!/bin/bash
# Script to easily access Rails console in production containers
# Usage: ./docker/rails-console.sh [container_name_or_id]

CONTAINER=${1:-$(docker ps --filter "label=service=web" --format "{{.Names}}" | head -1)}

if [ -z "$CONTAINER" ]; then
    echo "Error: No web container found. Please specify container name/ID."
    echo "Usage: $0 [container_name_or_id]"
    exit 1
fi

echo "Connecting to Rails console in container: $CONTAINER"
docker exec -it "$CONTAINER" bundle exec rails console