# frozen_string_literal: true

module Bi
  class HrCoreStaffInAndOutPolicy < Struct.new(:user, :dashboard)
    def show?
      user.present? &&
        (user.admin? || 
        user.roles.pluck(:role_name).any? { |r| r.in?['HR_集团人力相关人员','HR_集团高管','HR_IT和人力管理员']} )
    end
  end
end
