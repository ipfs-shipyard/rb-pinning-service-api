FROM ruby:2.7.2-alpine

ENV APP_ROOT /usr/src/app
ENV DATABASE_PORT 5432
WORKDIR $APP_ROOT

# =============================================
# System layer

# Will invalidate cache as soon as the Gemfile changes
COPY Gemfile Gemfile.lock $APP_ROOT/

# * Setup system
# * Install Ruby dependencies
RUN apk add --update \
    build-base \
    netcat-openbsd \
    git \
    shared-mime-info \
    nodejs \
    linux-headers \
    postgresql-dev \
    tzdata \
    curl-dev \
 && rm -rf /var/cache/apk/* \
 && gem update --system \
 && gem install bundler foreman \
 && bundle config --global frozen 1 \
 && bundle config set without 'test' \
 && bundle install --jobs 2

# ========================================================
# Application layer

# Copy application code
COPY . $APP_ROOT

# Precompile assets for a production environment.
# This is done to include assets in production images on Dockerhub.
RUN RAILS_ENV=production bundle exec rake assets:precompile

# Startup
CMD ["bin/docker-start"]
