#!/bin/bash
set -e

# Remove any existing server.pid file
rm -f /app/tmp/pids/server.pid

# Run database migrations if DB_MIGRATE is set
if [ "$DB_MIGRATE" = "true" ]; then
  echo "Running database migrations..."
  bundle exec rails db:migrate
fi

# Create database if it doesn't exist (useful for initial setup)
if [ "$DB_CREATE" = "true" ]; then
  echo "Creating database..."
  bundle exec rails db:create
fi

# Seed database if DB_SEED is set
if [ "$DB_SEED" = "true" ]; then
  echo "Seeding database..."
  bundle exec rails db:seed
fi

# Start the main process
exec "$@"