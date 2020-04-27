# frozen_string_literal: true

module Bi
  class GroupHrMonthlyPolicy < Struct.new(:user, :dashboard)
    def show?
      user.present? &&
        (user.roles.pluck(:hr_group_rt_reader).any? || user.admin?)
    end
  end
end
