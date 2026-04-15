FROM ruby:3.3.0-slim

# System deps
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      git \
      libpq-dev \
      pkg-config \
      curl \
      nodejs \
      npm && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

WORKDIR /rails

# Copy Gemfile only (lock may not exist yet)
COPY Gemfile ./
RUN bundle install --jobs 4 --retry 3

# Copy app
COPY . .

# Entrypoint
EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
