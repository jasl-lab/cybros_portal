set :nginx_use_ssl, true
set :branch, :thape

server 'thape_cybros', user: 'deployer', roles: %w{app db web}
