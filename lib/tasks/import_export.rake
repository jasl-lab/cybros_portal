# frozen_string_literal: true

namespace :import_export do
  desc 'Filling the comment for comment_on_sales_contract_code'
  task :filling_comment_on_sales_contract_code, [:csv_file] => [:environment] do |task, args|
    csv_file_path = args[:csv_file]
    CSV.foreach(csv_file_path, headers: true) do |row|
      Bi::CommentOnSalesContractCode.create(
        sales_contract_code: row['合同编号'],
        comment: row['情况说明及处理方法'],
        record_month: Date.today.end_of_month
      )
    end
  end

  desc 'Clean the PositionUser and DepartmentUser record'
  task clean_position_department_user: :environment do
    position_user_ids = SplitCost::UserMonthlyPartTimeSpecialJobType.all.distinct.pluck(:position_user_id)
    PositionUser.where.not(id: position_user_ids).delete_all
    DepartmentUser.delete_all
  end

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

  desc 'Create not existing position from CSV'
  task :create_new_position, [:csv_file] => [:environment] do |task, args|
    csv_file_path = args[:csv_file]
    CSV.foreach(csv_file_path, headers: true) do |row|
      dept_code = row['dept_code']
      nc_pk_post = row['nc_pk_post']

      position = Position.find_or_initialize_by(nc_pk_post: nc_pk_post)
      position.name = row['name']
      position.functional_category = row['functional_category']

      department = Department.find_by(dept_code: dept_code)
      position.department_id = department&.id

      position.b_postcode = row['b_postcode']
      position.b_postname = row['b_postname']
      position.save
      puts "Position nc_pk_post: #{nc_pk_post}"
    end
  end

  desc 'Create not existing user from CSV exported from oauth2id'
  task :create_new_user, [:csv_file] => [:environment] do |task, args|
    csv_file_path = args[:csv_file]
    CSV.foreach(csv_file_path, headers: true) do |row|
      email = row['email']
      position_title = row['position_title']
      gender = row['gender']
      clerk_code = row['clerk_code']
      pre_sso_id = row['pre_sso_id']
      wecom_id = row['wecom_id']
      job_level = row['job_level']
      major_code = row['major_code']
      major_name = row['major_name']
      entry_company_date = row['entry_company_date']
      locked_at = row['locked_at']
      chinese_name = row['chinese_name']
      mobile = row['mobile']
      desk_phone = row['desk_phone']
      combine_departments = row['combine_departments'].split(';')
      combine_positions = row['combine_positions'].split(';')

      user = User.find_or_create_by(email: email)
      user.position_title = position_title
      user.gender = gender
      user.clerk_code = clerk_code
      user.pre_sso_id = pre_sso_id
      user.wecom_id = wecom_id
      user.job_level = job_level
      user.major_code = major_code
      user.major_name = major_name
      user.entry_company_date = entry_company_date
      user.locked_at = locked_at
      user.chinese_name = chinese_name
      user.mobile = mobile
      user.desk_phone = desk_phone
      user.confirmed_at = Time.current
      random_password = SecureRandom.hex(4) # like "301bccce"
      user.password = random_password
      user.password_confirmation = random_password
      user.save

      puts "Updating user: #{user.id}"
      combine_departments.each do |cd|
        cds = cd.split('@')
        id = cds[0]
        department_name = cds[1]
        dept_code = cds[2]
        company_name = cds[3]
        company_code = cds[4]
        dept_category = cds[5]

        dep = Department.find_or_create_by(id: id) do |department|
          department.name = department_name
        end
        dep.update(company_name: company_name, company_code: company_code, dept_category: dept_category, name: department_name, dept_code: dept_code)
        DepartmentUser.find_or_create_by!(user_id: user.id, department_id: dep.id)
      end

      combine_positions.each do |cp|
        cps = cp.split('@')
        id = cps[0]
        position_name = cps[1]
        functional_category = cps[2]
        dept_code = cps[3]
        dept_name = cps[4]
        org_code = cps[5]
        nc_pk_post = cps[6]
        b_postcode = cps[7]
        b_postname = cps[8]
        dept_category = cps[9]
        org_name = cps[10]
        main_position = cps[11]
        post_level = cps[12]
        job_type_code = cps[13]

        dept = Department.find_or_initialize_by(dept_code: dept_code)
        dept.name = dept_name
        dept.company_code = org_code
        dept.dept_category = dept_category
        dept.company_name = org_name
        dept.save

        pos = Position.find_or_create_by(id: id) do |position|
          position.name = position_name
        end
        pos.update(functional_category: functional_category, name: position_name, department_id: dept.id,
          nc_pk_post: nc_pk_post, b_postcode: b_postcode, b_postname: b_postname)

        pu = PositionUser.find_or_create_by!(user_id: user.id, position_id: pos.id)
        ujt = SplitCost::UserJobType.find_by(code: job_type_code)
        pu.update(main_position: main_position, post_level: post_level, user_job_type_id: ujt&.id)
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
