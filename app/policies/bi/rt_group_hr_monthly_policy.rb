# frozen_string_literal: true

module Bi
  class RtGroupHrMonthlyPolicy < Struct.new(:user, :dashboard)
    def show?
      user.present? &&
        (user.roles.pluck(:hr_group_rt_reader).any? || \
         user.admin? ||
         user.roles.pluck(:role_name).any? { |r| r.in?(%w[HR_集团人力相关人员]) })
    end
  end
end
