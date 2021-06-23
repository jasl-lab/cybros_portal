# frozen_string_literal: true

# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

set :output, '/var/www/cybros_bi/shared/log/cron_log.log'

# Time is UTC
every 1.day, at: ['0:00', '2:00', '4:00', '6:00', '9:00'] do
  rake 'sync_yingjianke:sync_overrun_users'
end

every 1.day, at: '21:55' do
  command 'RAILS_ENV=production; cd /var/www/cybros/current/ && bundle exec pumactl -S /var/www/cybros/shared/tmp/pids/puma.state -F /var/www/cybros/shared/puma.rb restart'
end

every 1.day, at: '4:50' do
  rake 'sync_nc:all'
end

every :hour do
  runner 'Company::TianZhenLoginCount.record_count'
end

# Learn more: http://github.com/javan/whenever
