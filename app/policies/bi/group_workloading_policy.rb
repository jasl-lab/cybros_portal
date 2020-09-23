# frozen_string_literal: true

module Bi
  class GroupWorkloadingPolicy < Struct.new(:user, :dashboard)
    def show?
      return false unless user.present?

      user.roles.pluck(:report_viewer).any? \
      || user.roles.pluck(:report_view_all).any? \
      || user.operation_access_codes.any? { |c| c[0] <= User::ALL_EXCEPT_OTHER_COMPANY_DETAILS } \
      || user.admin?
    end
  end
end
