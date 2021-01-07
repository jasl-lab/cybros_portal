# frozen_string_literal: true

set :nginx_use_ssl, true
set :branch, :thape
set :puma_service_unit_name, :puma_prod
set :sidekiq_service_unit_name, 'sidekiq_prod'
set :sidekiq_service_unit_user, :system

server 'thape_cybros', user: 'deployer', roles: %w{app db web}
