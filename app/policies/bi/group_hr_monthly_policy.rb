# frozen_string_literal: true

module Bi
  class GroupHrMonthlyPolicy < Struct.new(:user, :dashboard)
    def show?
      user.present? &&
        ( user.roles.pluck(:hr_group_reader).any? || (user.roles.pluck(:role_name).any? { |r| r == 'HR_子公司总经理、董事长' }) ||
          user.admin? )
    end
  end
end
