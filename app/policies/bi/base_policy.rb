# frozen_string_literal: true

module Bi
  class BasePolicy < ApplicationPolicy
    def show?
      return false unless user.present?
      user.roles.pluck(:report_viewer).any? \
      || user.roles.pluck(:report_view_all).any? \
      || user.operation_access_codes.any? { |c| c[0] <= User::MY_COMPANY_EXCEPT_OTHER_DEPTS } || user.admin?
    end

    def export?
      show?
    end
  end
end
