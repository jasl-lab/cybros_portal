Sidekiq.configure_server do |config|
  config.average_scheduled_poll_interval = 1
  config.redis = { url: "redis://#{Rails.application.credentials.redis_server!}:#{Rails.application.credentials.redis_port!}/#{Rails.application.credentials[Rails.env.to_sym][:redis_db_num]}" }
end

Sidekiq.configure_client do |config|
  config.redis = { url: "redis://#{Rails.application.credentials.redis_server!}:#{Rails.application.credentials.redis_port!}/#{Rails.application.credentials[Rails.env.to_sym][:redis_db_num]}" }
end
