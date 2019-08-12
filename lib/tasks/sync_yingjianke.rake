namespace :sync_yingjianke do
  desc 'Sync overrun users in yingjianke'
  task sync_overrun_users: :environment do
    puts 'Sync overrun users in yingjianke'
    YingjiankeOverrunUser.rows.each do |r|
      timespan = (r[2] - r[1]) * 24
      if timespan >= 6
        user = YingjiankeOverrunUser.new do |u|
          u.time = DateTime.now
          u.stay_timespan = timespan
          u.device = r[4]
        end
        user.save
      end
    end
    YingjiankeOverrunUser.where("created_at < ?", 3.days.ago).delete_all
  end
end
