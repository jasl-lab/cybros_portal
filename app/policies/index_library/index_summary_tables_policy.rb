# frozen_string_literal: true

module IndexLibrary
  class IndexSummaryTablesPolicy < Struct.new(:user, :dashboard)
    def show?
      return false unless user.present?

      user.admin? ||
        user.roles.any? { |r| r.role_name == '天华指标库访问' }
    end
  end
end
