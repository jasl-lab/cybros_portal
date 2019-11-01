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

  desc 'Create not existing user from CSV exported from oauth2id'
  task :create_new_user, [:csv_file] => [:environment] do |task, args|
    csv_file_path = args[:csv_file]
    CSV.foreach(csv_file_path, headers: true) do |row|
      email = row['email']
      position_title = row['position_title']
      clerk_code = row['clerk_code']
      job_level = row['job_level']
      chinese_name = row['chinese_name']
      desk_phone = row['desk_phone']
      combine_departments = row['combine_departments'].split(';')

      user = User.find_or_create_by(email: email)
      user.position_title = position_title
      user.clerk_code = clerk_code
      user.job_level = job_level
      user.chinese_name = chinese_name
      user.desk_phone = desk_phone
      user.confirmed_at = Time.current
      random_password = SecureRandom.hex(4) # like "301bccce"
      user.password = random_password
      user.password_confirmation = random_password
      user.save

      combine_departments.each do |cd|
        id = cd.split('@')[0]
        department_name = cd.split('@')[1]
        company_name = cd.split('@')[2]

        dep = Department.find_or_create_by(id: id) do |department|
          department.name = department_name
        end
        dep.update(company_name: company_name, name: department_name)
        DepartmentUser.find_or_create_by!(user_id: user.id, department_id: dep.id)
      end
    end
  end
end
