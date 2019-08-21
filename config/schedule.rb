# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
every 1.day, at: ['8:00', '10:00', '12:00', '14:00', '17:00'] do
  rake "sync_yingjianke:sync_overrun_users"
end

every 1.day, at: "5:55" do
  command "RAILS_ENV=production; cd /var/www/cybros/current/ && bundle exec pumactl -S /var/www/cybros/shared/tmp/pids/puma.state -F /var/www/cybros/shared/puma.rb restart"
end
# Learn more: http://github.com/javan/whenever
