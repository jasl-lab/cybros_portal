set :nginx_use_ssl, false
set :branch, :thape

server 'thape_cybros', user: 'deployer', roles: %w{app db web}
