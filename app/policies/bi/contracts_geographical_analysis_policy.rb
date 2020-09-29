# frozen_string_literal: true

module Bi
  class ContractsGeographicalAnalysisPolicy < Struct.new(:user, :dashboard)
    def show?
      return false unless user.present?

      user.admin? \
        || user.operation_access_codes.any? { |c| c[0] <= User::ALL_EXCEPT_OTHER_COMPANY_DETAILS } \
        || user.roles.pluck(:group_report_viewer).any? \
        || user.chinese_name.in?(%w[王旭冉 王俐雯])
    end
  end
end
