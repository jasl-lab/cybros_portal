# frozen_string_literal: true

module Bi
  class RtGroupSubsidiaryHrMonthlyPolicy < Struct.new(:user, :dashboard)
    def show?
      user.present? &&
        (user.roles.pluck(:hr_subsidiary_rt_reader).any? ||
         user.roles.pluck(:role_name).any? { |r| r.in?(%w[HR_集团人力相关人员 HR_子公司总经理、董事长 HR_集团高管 HR_IT和人力管理员 HR_所级管理者 HR_填报人]) } ||
         user.admin?)
    end
  end
end
