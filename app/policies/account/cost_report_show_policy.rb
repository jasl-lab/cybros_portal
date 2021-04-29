# frozen_string_literal: true

module Account
  class CostReportShowPolicy < Struct.new(:user, :dashboard)
    def show?
      user.present? &&
        (user.admin? || user.roles.pluck(:role_name).any? { |r| r.in?(%w[CW_财务分析部管理员]) })
    end
  end
end
