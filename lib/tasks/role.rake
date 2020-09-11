namespace :role do
  desc "Filling HR role and CW roles"
  task :all => [:auto_hr_access_role, :create_hr_role_access, :auto_cw_access_role, :create_cw_role_access]

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
  task create_hr_role_access: :environment do
    ManualHrAccessCode.all.find_each do |ac|
      r = Role.find_by role_name: ac.hr_rolename
      if r.present?
        next if r.users.where(id: ac.user_id).exists?
        r.role_users.create(user_id: ac.user_id, auto_generated: true)
      else
        puts "ManualHrAccessCode id: #{ac.id}, hr_rolename: #{ac.hr_rolename} not existing."
      end
    end
  end

  desc 'Filling CW access code by logic'
  task auto_cw_access_role: :environment do
    ManualCwAccessCode.where(auto_generated_role: true).delete_all
    User.all.find_each do |user|
      cw_access_codes = user.cw_access_codes
      cw_access_codes.each  do |cw_access_code|
        orgcode = cw_access_code[0]
        deptcode_sum = cw_access_code[1]
        stname = cw_access_code[2]
        zjname = cw_access_code[3]
        next if stname.nil? || zjname.nil?

        if (stname.include?('总经理') || stname.include?('董事长') || stname.include?('总建筑师')) && zjname >= 17
          user.manual_cw_access_codes.create(cw_rolename: 'CW_子公司高管1', org_code: orgcode, dept_code: deptcode_sum, auto_generated_role: true)
        elsif (stname.include?('副总经理') || stname.include?('总经理助理')) && zjname >= 15
          user.manual_cw_access_codes.create(cw_rolename: 'CW_子公司高管2', org_code: orgcode, dept_code: deptcode_sum, auto_generated_role: true)
        elsif (stname.include?('管理副所长') && zjname >= 13) || (stname.include?('所长') && zjname >= 14) || (stname.include?('所长助理') && zjname >= 12)
          user.manual_cw_access_codes.create(cw_rolename: 'CW_所级管理者1', org_code: orgcode, dept_code: deptcode_sum, auto_generated_role: true)
        elsif (stname.include?('副所长') || stname.include?('商务经理')) && zjname >= 11
          user.manual_cw_access_codes.create(cw_rolename: 'CW_所级管理者2', org_code: orgcode, dept_code: deptcode_sum, auto_generated_role: true)
        end
      end
    end
  end

  desc 'Create role for having CW access code users'
  task create_cw_role_access: :environment do
    ManualCwAccessCode.all.find_each do |cw|
      r = Role.find_by role_name: cw.cw_rolename
      if r.present?
        next if r.users.where(id: cw.user_id).exists?
        r.role_users.create(user_id: cw.user_id, auto_generated: true)
      else
        puts "ManualCwAccessCode id: #{cw.id}, cw_rolename: #{cw.cw_rolename} not existing."
      end
    end
  end
end
