# frozen_string_literal: true

module Bi
  class HrYearDismissPolicy < Struct.new(:user, :dashboard)
    def show?
      user.present? &&
        (user.roles.pluck(:role_name).any? { |r| r.in?(%w[HR_IT和人力管理员 HR_集团高管 HR_集团人力相关人员]) } ||
         user.admin?)
    end
  end
end
