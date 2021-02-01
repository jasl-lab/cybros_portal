# frozen_string_literal: true

namespace :tianhua_bill do
  desc 'Dump the access log'
  task :dump_the_access_log, [:file_path] => [:environment] do |task, args|
    file_path = args[:file_path]
    File.readlines(file_path).each do |line|
      c1 = line.index(']')
      fcs = line[0..c1].split(' ')
      ip = fcs[0]
      full_time = fcs[3][1..]
      date = full_time[0..(full_time.index(':') - 1)]
      time = full_time[(full_time.index(':') + 1)..]

      scs = line[(c1 + 1)..].split(' ')
      action = scs[0][1..]
      url = scs[1]
      code = scs[3]

      clerk_code = url.split('/')[2]
      real_clerk_code = clerk_code.present? ? format('%06d', clerk_code.to_i) : nil

      user = User.find_by(clerk_code: real_clerk_code)

      puts "#{ip}\t#{date}\t#{time} +0800\t#{action}\t#{url}\t#{code}\t#{real_clerk_code}\t#{user&.chinese_name}\t#{user&.user_company_short_name}"
    end
  end
end
