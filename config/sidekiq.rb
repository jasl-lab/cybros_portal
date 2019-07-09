Sidekiq.configure_server do |config|
  config.poll_interval = 2
  config.redis = { url: "redis://#{Rails.application.secrets.redis_server!}:#{Rails.application.secrets.redis_port!}/#{Rails.application.secrets.redis_db_num!}" }
end

Sidekiq.configure_client do |config|
  config.redis = { url: "redis://#{Rails.application.secrets.redis_server!}:#{Rails.application.secrets.redis_port!}/#{Rails.application.secrets.redis_db_num!}" }
end
