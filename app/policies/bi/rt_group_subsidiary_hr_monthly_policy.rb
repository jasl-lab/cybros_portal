# frozen_string_literal: true

module Bi
  class RtGroupSubsidiaryHrMonthlyPolicy < Struct.new(:user, :dashboard)
    def show?
      user.present? &&
        (user.roles.pluck(:hr_subsidiary_rt_reader).any? ||
          (user.roles.pluck(:role_name).any? { |r| r == 'HR_所级管理者' }) ||
          user.admin?)
    end
  end
end
