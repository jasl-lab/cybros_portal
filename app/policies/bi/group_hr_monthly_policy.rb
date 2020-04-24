# frozen_string_literal: true

module Bi
  class GroupHrMonthlyPolicy < Struct.new(:user, :dashboard)
    def show?
      user.present? &&
        (user.roles.pluck(:hr_report_admin).any? || user.admin?)
    end
  end
end
