# frozen_string_literal: true

require_relative 'boot'

require 'csv'
require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
# require "action_mailbox/engine"
require 'action_text/engine'
require 'action_view/railtie'
require 'action_cable/engine'
# require "sprockets/railtie"
require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Require monkey patches
Dir[Pathname.new(File.dirname(__FILE__)).realpath.parent.join('lib', 'monkey_patches', '*.rb')].map do |file|
  require file
end

module CybrosCore
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]

    config.generators do |g|
      g.helper false
      g.assets false
      g.test_framework nil
    end

    overrides = "#{Rails.root}/app/overrides"
    Rails.autoloaders.main.ignore(overrides)
    config.to_prepare do
      Dir.glob("#{overrides}/**/*_override.rb").each do |override|
        load override
      end
    end

    # Read ActionMailer config from config/mailer.yml
    initializer 'action_mailer.set_configs.set_yaml_configs', before: 'action_mailer.set_configs' do |app|
      next unless File.exist?(Rails.root.join('config', 'mailer.yml'))

      configure = app.config_for('mailer').deep_symbolize_keys
      configure.each do |key, value|
        setter = "#{key}="
        unless app.config.action_mailer.respond_to? setter
          raise "Can't set option `#{key}` to ActionMailer, make sure that options in config/mailer.yml are valid."
        end

        app.config.action_mailer.send(setter, value)
      end
    end

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.time_zone = 'Asia/Shanghai'
    config.i18n.default_locale = 'zh-CN'
    config.beginning_of_week = :sunday # for simple_calendar
  end
end

require Rails.root.join('lib', 'aes_encrypt_decrypt.rb')
