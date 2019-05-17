set :nginx_use_ssl, true
set :branch, :thape_staging
set :deploy_to, "/var/www/staging"

server 'thape_cybros', user: 'staging', roles: %w{app db web}
