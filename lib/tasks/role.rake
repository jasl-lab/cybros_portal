namespace :role do
  desc 'Filling HR access code by logic'
  task auto_hr_access_role: :environment do
    ManualHrAccessCode.where(auto_generated_role: true).delete_all
    User.all.find_each do |user|
      hr_access_codes = user.hr_access_codes
      hr_access_codes.each  do |hr_access_code|
        orgcode = hr_access_code[0]
        deptcode_sum = hr_access_code[1]
        stname = hr_access_code[2]
        zjname = hr_access_code[3]
        next if stname.nil? || zjname.nil?

        if (stname.include?('总经理') || stname.include?('董事长')) && zjname >= 17
          user.manual_hr_access_codes.create(hr_rolename: 'HR_子公司总经理、董事长', org_code: orgcode, dept_code: deptcode_sum, auto_generated_role: true)
        elsif stname.include?('所长') && zjname >= 14
          user.manual_hr_access_codes.create(hr_rolename: 'HR_所级管理者', org_code: orgcode, dept_code: deptcode_sum, auto_generated_role: true)
        elsif stname.include?('管理副所长') && zjname >= 13
          user.manual_hr_access_codes.create(hr_rolename: 'HR_所级管理者', org_code: orgcode, dept_code: deptcode_sum, auto_generated_role: true)
        end
      end
    end
  end

  desc 'Create role for having HR access code users'
  task create_role_access: :environment do
    ManualHrAccessCode.all.find_each do |ac|
      r = Role.find_by role_name: ac.hr_rolename
      if r.present?
        next r.users.where(id: ac.user_id).exists?
        r.role_users.create(user_id: ac.user_id)
      else
        puts "ManualHrAccessCode id: #{ac.id}, hr_rolename: #{ac.hr_rolename} not existing."
      end
    end
  end
end
