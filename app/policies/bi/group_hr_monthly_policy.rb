# frozen_string_literal: true

module Bi
  class GroupHrMonthlyPolicy < Struct.new(:user, :dashboard)
    def show?
      user.present? &&
<<<<<<< Updated upstream
      (user.roles.pluck(:hr_group_reader).any? ||
       user.roles.pluck(:role_name).any? { |r| r.in?(%w[HR_集团人力相关人员 HR_子公司总经理、董事长 HR_集团高管 HR_人力资源报表责任人 HR_人力资源报表HR经理 HR_IT和人力管理员]) } ||
       user.admin?)
=======
        ( user.roles.pluck(:role_name).any? { |r| r.in?['HR_集团人力相关人员','HR_子公司总经理、董事长','HR_集团高管','HR_人力资源报表责任人','HR_人力资源报表HR经理','HR_IT和人力管理员']} ||
        user.admin? )
>>>>>>> Stashed changes
    end
  end
end
