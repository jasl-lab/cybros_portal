namespace :sync_yingjianke do
  desc 'Sync overrun users in yingjianke'
  task sync_overrun_users: :environment do
    puts 'Sync overrun users in yingjianke'
    rows = YingjianekeLoginsController.rows
    rows.each do |r|
      timespan = (r[2] - r[1]) * 24
      if timespan >= 6
        user = YingjiankeOverrunUser.new do |u|
          u.time = DateTime.now
          u.timespan = timespan
          u.device = r[4]
        end
        user.save
      end
    end
  end
end
