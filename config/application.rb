# frozen_string_literal: true

require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"

Bundler.require(*Rails.groups)

module StratifyCoreBackend
  class Application < Rails::Application
    config.load_defaults 7.1
    config.api_only = true

    config.time_zone = "UTC"
    config.active_record.default_timezone = :utc

    # CORS — permitir requisições do Desktop Client (Tauri local)
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins "*"
        resource "*", headers: :any, methods: [:get, :post, :put, :patch, :delete, :options, :head]
      end
    end
  end
end
