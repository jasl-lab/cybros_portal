# frozen_string_literal: true

namespace :import_export do
  desc 'Filling CSV file to subsidiary_workloadings'
  task :subsidiary_workloadings, [:csv_file] => [:environment] do |task, args|
    csv_file_path = args[:csv_file]
    CSV.foreach(csv_file_path, headers: true) do |row|
      Bi::WorkHoursCountOrg.create(
        company: row['公司'],
        date: row['日期'],
        need_days: row['天数需填'],
        acturally_days: row['天数实填'],
        planning_need_days: row['方案需填'],
        planning_acturally_days: row['方案实填'],
        building_need_days: row['施工图需填'],
        building_acturally_days: row['施工图实填'],
      )
    end
  end

  desc 'Filling CSV file to manual_hr_access_codes'
  task :manual_hr_access_codes, [:csv_file] => [:environment] do |task, args|
    csv_file_path = args[:csv_file]
    CSV.foreach(csv_file_path, headers: true) do |row|
      next if row['email'].blank?

      user = User.find_by email: row['email']
      if user.present?
        user.manual_hr_access_codes.create(hr_rolename: row['role'], org_code: row['orgcode'], dept_code: row['deptcode_sum'])
      else
        puts "email: #{row['email']} not existing"
      end
    end
  end

  desc 'Create not existing user from CSV exported from oauth2id'
  task :create_new_user, [:csv_file] => [:environment] do |task, args|
    csv_file_path = args[:csv_file]
    CSV.foreach(csv_file_path, headers: true) do |row|
      email = row['email']
      position_title = row['position_title']
      clerk_code = row['clerk_code']
      pre_sso_id = row['pre_sso_id']
      job_level = row['job_level']
      locked_at = row['locked_at']
      chinese_name = row['chinese_name']
      desk_phone = row['desk_phone']
      combine_departments = row['combine_departments'].split(';')

      user = User.find_or_create_by(email: email)
      user.position_title = position_title
      user.clerk_code = clerk_code
      user.pre_sso_id = pre_sso_id
      user.job_level = job_level
      user.locked_at = locked_at
      user.chinese_name = chinese_name
      user.desk_phone = desk_phone
      user.confirmed_at = Time.current
      random_password = SecureRandom.hex(4) # like "301bccce"
      user.password = random_password
      user.password_confirmation = random_password
      user.save

      combine_departments.each do |cd|
        cds = cd.split('@')
        id = cds[0]
        department_name = cds[1]
        dept_code = cds[2]
        company_name = cds[3]
        company_code = cds[4]

        dep = Department.find_or_create_by(id: id) do |department|
          department.name = department_name
        end
        dep.update(company_name: company_name, company_code: company_code, name: department_name, dept_code: dept_code)
        DepartmentUser.find_or_create_by!(user_id: user.id, department_id: dep.id)
      end
    end
  end

  desc 'Generate the VPN report'
  task :vpn_csv_report, [:csv_file] => [:environment] do |task, args|
    csv_file_path = args[:csv_file]

    CSV.open('vpn_report.csv', 'w') do |csv|
      csv << %w[user_name chinese_name department company action state]

      CSV.foreach(csv_file_path, headers: true) do |row|
        user_name = row['1']
        action = row['2']
        state = row['3']

        user = User.find_by email: "#{user_name}@thape.com.cn"
        if user.present?
          values = []
          values << user_name
          values << user.chinese_name
          values << user.user_department_name
          values << user.user_company_short_name
          values << action
          values << state
          csv << values
        else
          puts "Username: #{user_name} can not find."
        end
      end
    end
  end

  desc 'Generate the tianhua2019 report'
  task :tianhua2019_report, [:log_file] => [:environment] do |task, args|
    REGEXP = /(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s?\-\s?-\s?\[(\d{2}\/[a-z]{3}\/\d{4}:\d{2}:\d{2}:\d{2} (\+|\-)\d{4})\]\s?\\?"?(GET|POST|PUT|HEAD|DELETE|OPTIONS)\s?(.*?)\s(HTTP\/\d\.\d)\\?"?\s?(\d{3})\s?(\d+)\s?\\?\"\-\\?\"\s?\\?\"(.*?)\"/i

    CSV.open('tianhua2019.csv', 'w') do |csv|
      csv << %w[ip time clerk_code chinese_name position_title company_short_name department_name user_agent]

      File.foreach(args[:log_file]) do |line|
        matches = line.match(REGEXP)
        next if matches.nil?

        ip = matches[1]
        time_str = matches[2]
        time = DateTime.strptime(time_str, '%d/%b/%Y:%H:%M:%S %z')
        url = matches[5]
        clerk_code = url[14..19]
        user_agent = matches[9]
        user = User.find_by(clerk_code: clerk_code)
        if user.present?
          values = []
          values << ip
          values << time
          values << clerk_code
          values << user.chinese_name
          values << user.position_title
          values << user.user_company_names&.first
          values << user.user_department_name
          values << user_agent
          csv << values
        end
      end
    end
  end

  desc 'Import NC fa_card into cybros'
  task nc_fa_card_import: :environment do
    Nc::FaCard.where('LENGTH(asset_code) < 12').each do |f|
      sci = SplitCost::SplitCostItem.find_or_initialize_by(split_cost_item_no: f.asset_code)
      sci.split_cost_item_name = f.asset_name
      sci.split_cost_item_category = '固定资产'
      sci.save
    end
  end

  desc 'Import NC in_out_biz into cybros'
  task nc_in_out_biz_import: :environment do
    Nc::InOutBiz.all.each do |iob|
      sci = SplitCost::SplitCostItem.find_or_initialize_by(split_cost_item_no: iob.code)
      sci.split_cost_item_name = iob.name
      sci.split_cost_item_category = '业务性支出预算'
      sci.from_dept_code = iob.deptcode
      sci.save
    end
  end
end
