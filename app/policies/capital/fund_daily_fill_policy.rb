# frozen_string_literal: true

module Capital
  class FundDailyFillPolicy < Struct.new(:user, :dashboard)
    def show?
      return false unless user.present?

      user.admin? || \
        user.roles.pluck(:role_name).any? { |r| r.in?(%w[CW_财务管理员 CW_会计填报人]) }
    end
  end
end
