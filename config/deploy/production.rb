set :nginx_use_ssl, true
set :branch, :thape
set :puma_service_unit_name, :puma_prod

server 'thape_cybros', user: 'deployer', roles: %w{app db web}
