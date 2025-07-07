# Docker Setup for CM42 Central

This document explains the Docker setup for deploying CM42 Central to Railway and other container platforms.

## Architecture

The application is split into two Docker images:
- **Web**: Runs the Puma web server
- **Worker**: Runs Sidekiq for background job processing

Both images are built from a common base image for efficiency.

## Files Created

1. **Dockerfile** - Base image with Ruby 2.7.8, Node.js 20.17.0, and all dependencies
2. **Dockerfile.web** - Web server image with Puma
3. **Dockerfile.worker** - Worker image with Sidekiq
4. **docker/web-entrypoint.sh** - Entrypoint script for web container (handles migrations)
5. **docker/rails-console.sh** - Helper script for accessing Rails console
6. **.github/workflows/docker-build.yml** - GitHub Actions workflow for building/pushing images
7. **docker-compose.production.yml** - Local testing setup

## GitHub Container Registry Setup

The GitHub workflow automatically builds and pushes images to ghcr.io when you:
- Push to main/master branches
- Create a tag starting with 'v'

Images are tagged as:
- `ghcr.io/[org]/[repo]:web` - Latest web image
- `ghcr.io/[org]/[repo]:worker` - Latest worker image
- `ghcr.io/[org]/[repo]:web-[sha]` - Specific web build
- `ghcr.io/[org]/[repo]:worker-[sha]` - Specific worker build

## Railway Deployment

### 1. Create Two Services in Railway:
- **Web Service**: Use the `web` image
- **Worker Service**: Use the `worker` image

### 2. Configure Environment Variables:
Required for both services:
```bash
DATABASE_URL=postgresql://...
REDIS_URL=redis://...
SECRET_KEY_BASE=...
RAILS_ENV=production
```

Additional for web service:
```bash
DB_MIGRATE=true  # Run migrations on deploy
PORT=3000
```

Additional for worker service:
```bash
SIDEKIQ_CONCURRENCY=100  # Adjust as needed
```

### 3. Set Docker Images:
- Web: `ghcr.io/[your-org]/[your-repo]:web`
- Worker: `ghcr.io/[your-org]/[your-repo]:worker`

## Operational Tasks

### Access Rails Console
```bash
# On Railway (using Railway CLI)
railway run rails console

# On local Docker
./docker/rails-console.sh

# Or directly
docker exec -it [container_name] bundle exec rails console
```

### Run Database Migrations
Migrations run automatically on web container startup when `DB_MIGRATE=true`.

To run manually:
```bash
docker exec [container_name] bundle exec rails db:migrate
```

### View Logs
```bash
# Web logs
docker logs [web_container_name]

# Worker logs
docker logs [worker_container_name]
```

### Local Testing
```bash
# Build and run locally
docker-compose -f docker-compose.production.yml up --build

# Create .env.production file with your settings first
cp .env.sample .env.production
# Edit .env.production with production values
```

## Health Checks
- Web service: HTTP check on `/health` endpoint
- Worker service: Process check for Sidekiq

## Notes
- Assets are precompiled during build for better performance
- Both images run as non-root user (uid 1000) for security
- Supports both AMD64 and ARM64 architectures
- GitHub Actions caches layers for faster builds
- Web container handles database migrations automatically