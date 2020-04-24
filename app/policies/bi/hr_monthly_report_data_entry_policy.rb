# frozen_string_literal: true

module Bi
  class HrMonthlyReportDataEntryPolicy < Struct.new(:user, :dashboard)
    def show?
      user.present? &&
        (user.roles.pluck(:hr_report_admin).any? || user.roles.pluck(:hr_report_viewer).any? || user.roles.pluck(:hr_report_writer).any? || user.admin?)
    end
  end
end
