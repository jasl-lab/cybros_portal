# frozen_string_literal: true

module Capital
  class SalaryQueryPolicy < Struct.new(:user, :dashboard)
    def show?
      return false unless user.present?

      user.admin? || \
        user.roles.pluck(:role_name).any? { |r| r.in?(%w[CW-个税报表查询]) }
    end
  end
end
