# frozen_string_literal: true

set :nginx_use_ssl, true
set :branch, :thape
set :puma_service_unit_name, :puma_bi_prod
set :puma_systemctl_user, :system
set :sidekiq_service_unit_name, 'sidekiq_bi_prod'
set :sidekiq_service_unit_user, :system

server 'thape_vendor', user: 'cybros_bi', roles: %w{app db web}
