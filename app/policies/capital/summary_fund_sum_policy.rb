# frozen_string_literal: true

module Capital
  class SummaryFundSumPolicy < Struct.new(:user, :dashboard)
    def show?
      return false unless user.present?

      user.admin? || \
        user.roles.pluck(:role_name).any? { |r| r.in?(%w[CW_财务管理员]) } || \
          user.chinese_name.in?(%w(杨静怡 吕林 张永磊))
    end
  end
end
