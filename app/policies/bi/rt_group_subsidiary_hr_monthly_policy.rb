# frozen_string_literal: true

module Bi
  class RtGroupSubsidiaryHrMonthlyPolicy < Struct.new(:user, :dashboard)
    def show?
      user.present? &&
        (user.roles.pluck(:hr_report_writer).any? || user.roles.pluck(:hr_report_admin).any? || user.admin?)
    end
  end
end
