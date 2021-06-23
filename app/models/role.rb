# frozen_string_literal: true

class Role < ApplicationRecord
  has_many :role_users
  has_many :users, through: :role_users
  validates :role_name, presence: true

  CREATIVE_SECTION = %w[上海天华建筑设计有限公司 香港天华建筑设计有限公司 EID GROUP LIMITED 天津天华北方建筑设计有限公司 沈阳天华建筑设计有限公司 北京天华北方建筑设计有限公司 深圳市天华建筑设计有限公司 武汉天华华中建筑设计有限公司 成都天华西南建筑设计有限公司 西安天华建筑设计有限公司 上海天华城市规划设计有限公司 上海天华室内设计有限公司 上海天华园林景观有限公司 重庆天华建筑设计有限公司 武汉天华嘉易建筑设计有限公司 厦门天华建筑设计有限公司 上海易术家互娱科技有限公司 青岛天华易境建筑设计有限公司 爱坤（上海）室内设计咨询有限公司 易爱迪（上海）建筑设计有限公司 南京天华江南建筑设计有限公司 郑州天华建筑设计有限公司 杭州天华建筑设计有限公司 广州天华建筑设计有限公司 合肥天华嘉易建筑设计有限公司 AICO（上海）建筑设计有限公司 深圳天华易筑室内设计有限公司 武汉天华易筑室内设计有限公司 济南天华建筑设计有限公司 昆明天华建筑设计有限公司 贵阳天华建筑设计有限公司]

  def self.sync_all
    Role.clean_auto_generated_role_access
    Role.auto_hr_access_role
    Role.create_hr_role_access
    Role.auto_cw_access_role
    Role.create_cw_role_access
  end

  def self.clean_auto_generated_role_access
    RoleUser.where(auto_generated: true).delete_all
  end

  def self.auto_hr_access_role
    ManualHrAccessCode.where(auto_generated_role: true).delete_all
    User.all.find_each do |user|
      hr_access_codes = user.hr_access_codes
      hr_access_codes.each  do |hr_access_code|
        orgcode = hr_access_code[0]
        deptcode_sum = hr_access_code[1]
        stname = hr_access_code[2]
        zjname = hr_access_code[3]
        chinese_name = hr_access_code[4]
        next if stname.nil? || zjname.nil? || %w[夏馥莹 张骏].include?(chinese_name)

        if (stname == '总经理' || stname == '董事长') && zjname >= 17
          user.manual_hr_access_codes.create(hr_rolename: 'HR_子公司总经理、董事长', org_code: orgcode, dept_code: deptcode_sum, auto_generated_role: true)
        elsif stname.include?('所长') && zjname >= 14
          user.manual_hr_access_codes.create(hr_rolename: 'HR_所级管理者', org_code: orgcode, dept_code: deptcode_sum, auto_generated_role: true)
        elsif stname.include?('管理副所长') && zjname >= 13
          user.manual_hr_access_codes.create(hr_rolename: 'HR_所级管理者', org_code: orgcode, dept_code: deptcode_sum, auto_generated_role: true)
        end
      end
    end
  end

  def self.create_hr_role_access
    ManualHrAccessCode.all.find_each do |ac|
      r = Role.find_by role_name: ac.hr_rolename
      if r.present?
        next if r.users.where(id: ac.user_id).exists?
        r.role_users.create(user_id: ac.user_id, auto_generated: ac.auto_generated_role)
      else
        puts "ManualHrAccessCode id: #{ac.id}, hr_rolename: #{ac.hr_rolename} not existing."
      end
    end
  end

  def self.auto_cw_access_role
    ManualCwAccessCode.where(auto_generated_role: true).delete_all
    User.all.find_each do |user|
      cw_access_codes = user.cw_access_codes
      cw_access_codes.each  do |cw_access_code|
        orgcode = cw_access_code[0]
        deptcode_sum = cw_access_code[1]
        stname = cw_access_code[2]
        zjname = cw_access_code[3]
        chinese_name = cw_access_code[4]
        next if stname.nil? || zjname.nil? || %w[夏馥莹 张骏].include?(chinese_name)

        if (stname.include?('总经理') || stname.include?('董事长') || stname.include?('总建筑师')) && zjname >= 17
          user.manual_cw_access_codes.create(cw_rolename: 'CW_子公司高管1', org_code: orgcode, dept_code: deptcode_sum, auto_generated_role: true)
        elsif (stname == '副总经理' || stname == '总经理助理' || stname == '市场运营总监' || stname == 'Marketing & Operation Director 市场运营总监') && zjname >= 15
          user.manual_cw_access_codes.create(cw_rolename: 'CW_子公司高管2', org_code: orgcode, dept_code: deptcode_sum, auto_generated_role: true)
        elsif (stname.include?('管理副所长') && zjname >= 13) || (stname.include?('所长') && zjname >= 14) || (stname.include?('所长助理') && zjname >= 12)
          user.manual_cw_access_codes.create(cw_rolename: 'CW_所级管理者1', org_code: orgcode, dept_code: deptcode_sum, auto_generated_role: true)
        elsif (stname.include?('副所长') || stname.include?('商务经理')) && zjname >= 11
          user.manual_cw_access_codes.create(cw_rolename: 'CW_所级管理者2', org_code: orgcode, dept_code: deptcode_sum, auto_generated_role: true)
        end
      end
    end
  end

  def self.create_cw_role_access
    ManualCwAccessCode.all.find_each do |cw|
      r = Role.find_by role_name: cw.cw_rolename
      if r.present?
        next if r.users.where(id: cw.user_id).exists?
        r.role_users.create(user_id: cw.user_id, auto_generated: cw.auto_generated_role)
      else
        puts "ManualCwAccessCode id: #{cw.id}, cw_rolename: #{cw.cw_rolename} not existing."
      end
    end
  end
end
