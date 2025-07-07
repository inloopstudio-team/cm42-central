# syntax=docker/dockerfile:1
FROM ruby:2.7.8-slim AS base

# Install base packages
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        git \
        libpq-dev \
        libxml2-dev \
        libxslt-dev \
        postgresql-client \
        imagemagick \
        libvips \
        tzdata \
        ca-certificates \
        gnupg \
        lsb-release \
        && rm -rf /var/lib/apt/lists/*

# Install Node.js 20.x and Yarn
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get update -qq && \
    apt-get install -y nodejs && \
    npm install -g yarn && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install bundler
RUN gem install bundler -v 2.4.22

# Copy Gemfile and install dependencies
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local deployment 'true' && \
    bundle config set --local without 'development test' && \
    bundle install --jobs 4 --retry 3

# Copy package.json and yarn.lock and install Node dependencies
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile --production

# Copy application code
COPY . .

# Precompile assets
RUN SECRET_KEY_BASE=dummy bundle exec rails assets:precompile

# Create non-root user
RUN useradd -m -u 1000 rails && \
    chown -R rails:rails /app

USER rails

# Set Rails environment
ENV RAILS_ENV=production \
    NODE_ENV=production \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true

# Expose port (for web service)
EXPOSE 3000