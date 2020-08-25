# frozen_string_literal: true

module Bi
  class RtGroupHrMonthlyPurePolicy < Struct.new(:user, :dashboard)
    def show?
      user.present? &&
        ( user.admin? || user.roles.any? { |r| r.role_name == 'HR_IT和人力管理员' } )
    end
  end
end
