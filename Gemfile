source "https://rubygems.org"

ruby "3.2.2"

gem "rails", "~> 7.1.0"

gem "pg", "~> 1.5"
gem "puma", "~> 6.0"
gem "redis", "~> 5.0"
gem "sidekiq", "~> 7.0"

gem "sprockets-rails"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"

gem "jbuilder"
gem "bootsnap", require: false

gem "image_processing", "~> 1.2"
gem "aws-sdk-s3", require: false

gem "devise", "~> 4.9"
gem "omniauth", "~> 2.1"
gem "omniauth-google-oauth2"
gem "omniauth-facebook"
gem "omniauth-rails_csrf_protection"

gem "ransack", "~> 4.0"
gem "pg_search", "~> 2.3"
gem "pagy", "~> 6.0"

gem "stripe", "~> 10.0"
gem "mercadopago-sdk", "~> 2.0"

gem "prawn", "~> 2.4"
gem "prawn-table", "~> 0.2"
gem "caxlsx", "~> 3.3"

gem "money-rails", "~> 1.15"

gem "friendly_id", "~> 5.5"

gem "pundit", "~> 2.3"

gem "kaminari", "~> 1.2"

gem "aasm", "~> 5.5"

gem "rack-cors"

gem "dotenv-rails", groups: [:development, :test]

group :development, :test do
  gem "debug", platforms: %i[mri windows]
  gem "rspec-rails", "~> 6.0"
  gem "factory_bot_rails", "~> 6.2"
  gem "faker", "~> 3.2"
  gem "shoulda-matchers", "~> 5.3"
  gem "database_cleaner-active_record"
end

group :development do
  gem "web-console"
  gem "rack-mini-profiler"
  gem "spring"
  gem "annotate"
  gem "bullet"
  gem "brakeman"
  gem "rubocop-rails", require: false
  gem "letter_opener_web"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "webmock"
  gem "vcr"
  gem "simplecov", require: false
end
