# frozen_string_literal: true

source "https://gems.ruby-china.com"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby ">= 2.6"

gem "rails", "~> 6.0.3"
gem "rails-i18n"

gem "auto_strip_attributes"

# Use postgresql as the database for Active Record
# gem "pg", ">= 0.18", "< 2.0"
# Use sqlite as the database for Active Record
gem "mysql2"

gem 'tiny_tds', '~> 2.1.3'
# bundle config local.activerecord-sqlserver-adapter /Users/guochunzhong/git/oss/activerecord-sqlserver-adapter/
gem 'activerecord-sqlserver-adapter', git: 'https://github.com/rails-sqlserver/activerecord-sqlserver-adapter', branch: 'master'

# Use Oracle to fetch NC data
gem 'ruby-oci8'
gem 'activerecord-oracle_enhanced-adapter'

gem "sidekiq", "~> 5.2.7"

# Use Puma as the app server
gem "puma", "~> 4.3.0"
# Use development version of Webpacker
gem "webpacker", "~> 5.2"

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem "turbolinks", "~> 5"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.5"

gem 'http', '~> 4.1'

# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.4.4", require: false

gem "config"

gem "devise"
gem "omniauth_openid_connect"
gem "devise_invitable"
gem "devise-i18n"
gem "devise-jwt"
# bundle config local.pundit /Users/guochunzhong/git/oss/pundit/
gem "pundit", git: 'https://github.com/thape-cn/pundit', branch: :master

gem "meta-tags"

gem "browser"
gem 'server_timing'

gem "ajax-datatables-rails"
gem "kaminari"

gem "simple_calendar"

# bundle config local.wechat /Users/guochunzhong/git/oss/wechat/
gem 'wechat', git: 'https://github.com/Eric-Guo/wechat', branch: :main

gem 'jieba-rb'
gem 'similar_text'

gem 'whenever', require: false

gem 'geocoder'

group :production do
  gem 'dalli'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "web-console"
  gem "listen"

  gem "brakeman", require: false
  gem "rubocop", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-performance", require: false

  gem "capistrano"
  gem "capistrano-rails"
  gem "capistrano-rbenv"
  gem "capistrano3-puma"
  gem "capistrano-sidekiq"
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem "capybara", ">= 2.15"
  gem "selenium-webdriver"
  gem "webdrivers"
end

group :circle_ci do
  gem "minitest-ci"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]
