# frozen_string_literal: true

module Capital
  class SummaryFundMonthPolicy < Struct.new(:user, :dashboard)
    def show?
      return false unless user.present?

      user.admin? || \
        user.roles.pluck(:role_name).any? { |r| r.in?(%w[CW_财务管理员]) }
    end
  end
end
