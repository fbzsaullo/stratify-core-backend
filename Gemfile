source "https://rubygems.org"
ruby "3.3.0"

gem "rails", "~> 7.1"
gem "pg", "~> 1.5"
gem "puma", ">= 5.0"
gem "redis", "~> 5.0"

# Auth
gem "devise"
gem "devise-jwt"

# Serialization
gem "jsonapi-serializer"

# Event Bus
gem "redis-client"

# Schema Validation
gem "dry-schema"
gem "dry-validation"

# Background Jobs
gem "sidekiq", "~> 7.0"

# Monitoring
gem "sentry-ruby"
gem "sentry-rails"

group :development, :test do
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "faker"
  gem "pry-byebug"
end

group :development do
  gem "rubocop-rails-omakase", require: false
end
