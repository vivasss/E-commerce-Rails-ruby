require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module Elixer
  class Application < Rails::Application
    config.load_defaults 7.1
    
    config.autoload_lib(ignore: %w[assets tasks])
    
    config.time_zone = "America/Sao_Paulo"
    
    config.i18n.default_locale = :"pt-BR"
    config.i18n.available_locales = [:"pt-BR", :en]
    
    config.active_job.queue_adapter = :sidekiq
    
    config.cache_store = :redis_cache_store, {
      url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"),
      namespace: "elixer_cache"
    }
    
    config.session_store :redis_store, {
      servers: [ENV.fetch("REDIS_URL", "redis://localhost:6379/0")],
      expire_after: 1.week,
      key: "_elixer_session",
      threadsafe: true
    }
    
    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
      g.test_framework :rspec,
        fixtures: false,
        view_specs: false,
        helper_specs: false,
        routing_specs: false
      g.fixture_replacement :factory_bot, dir: "spec/factories"
    end
    
    config.action_mailer.default_url_options = { host: ENV.fetch("APP_HOST", "localhost:3000") }
  end
end
